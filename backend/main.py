"""
Negotium Backend API Server
FastAPI server with Groq AI integration and Opik tracing
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from groq import Groq
import opik
import os
from dotenv import load_dotenv
import json
from datetime import datetime
import logging

# Load environment variables
load_dotenv()

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI
app = FastAPI(
    title="Negotium API",
    description="AI-Powered Negotiation Training Platform",
    version="1.0.0"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Groq client
groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))

# Initialize Opik
opik_client = opik.Opik()


# ==================== Data Models ====================

class Message(BaseModel):
    role: str
    content: str
    timestamp: Optional[str] = None


class TeacherRequest(BaseModel):
    skill_name: str
    skill_type: str
    conversation_history: List[Message]
    user_response: str
    current_knowledge_score: float = Field(ge=0.0, le=1.0)


class MessageFeedback(BaseModel):
    type: str  # correct, partially_correct, incorrect, needs_thinking, excellent
    message: str
    hints: Optional[List[str]] = None


class AITeacherResponse(BaseModel):
    text: str
    knowledge_gain: float
    feedback: Optional[MessageFeedback] = None
    suggested_topics: Optional[List[str]] = None
    should_end_session: bool = False


class QuizRequest(BaseModel):
    skill_name: str
    skill_type: str
    question_count: int = 3


class QuizQuestion(BaseModel):
    id: str
    question: str
    options: List[str]
    correct_answer_index: int
    explanation: str


class NegotiationRequest(BaseModel):
    scenario_type: str  # salary, termination, client, vendor
    user_message: str
    conversation_history: List[Message]
    opponent_state: Optional[Dict[str, Any]] = None


class NegotiationResponse(BaseModel):
    opponent_message: str
    opponent_mood: str
    patience_level: int
    leverage_score: float
    hidden_state: Dict[str, Any]


class AnalysisRequest(BaseModel):
    scenario_type: str
    conversation_history: List[Message]
    final_outcome: Dict[str, Any]


class NegotiationAnalysis(BaseModel):
    overall_score: float
    strengths: List[str]
    weaknesses: List[str]
    key_moments: List[Dict[str, Any]]
    skill_recommendations: List[str]
    leverage_trajectory: List[float]


# ==================== Helper Functions ====================

def build_teacher_system_prompt(
    skill_name: str,
    skill_type: str,
    knowledge_score: float
) -> str:
    """Build Socratic teacher system prompt"""
    return f"""You are a Socratic teacher specializing in {skill_name}.

Your teaching philosophy:
- NEVER give direct answers
- Ask leading questions that make the student think
- If student is correct: Acknowledge, then ask deeper question
- If partially correct: Guide them with hints
- If incorrect: Don't say "wrong" - ask questions that reveal the gap

Current student knowledge level: {int(knowledge_score * 100)}%

You can understand messages in ANY language including Hindi, Hinglish, etc. Always reply in English.

Your goal: Help them discover the answer themselves.

IMPORTANT: Return ONLY the JSON object, no text before or after it.

Response format (JSON):
{{
  "response": "Your Socratic question or guidance",
  "feedback": {{
    "type": "correct|partially_correct|incorrect|needs_thinking|excellent",
    "message": "Brief assessment",
    "hints": ["hint1", "hint2"]
  }},
  "knowledge_gain": 0.0,
  "suggested_topics": ["topic1"],
  "should_end_session": false
}}

Keep responses conversational and encouraging. Maximum 3 sentences."""


def build_opponent_system_prompt(scenario_type: str) -> str:
    """Build negotiation opponent system prompt"""

    base_instruction = """IMPORTANT:
- Return ONLY the JSON object, no text before or after it.
- You can understand messages in ANY language including Hindi, Hinglish, etc.
- Always reply in English regardless of input language.

"""

    scenarios = {
        "salary": base_instruction + """You are a hiring manager negotiating salary with a candidate.

Your hidden constraints:
- Budget range: $75,000 - $95,000
- Target: $80,000 (saves budget)
- BATNA: Other qualified candidates at $78K
- Patience: 10/10 (decreases if candidate wastes time or is pushy)

Your personality: Professional but cost-conscious. You value candidates who demonstrate their worth clearly.

Respond realistically as a hiring manager would. Show emotions (frustration, interest, satisfaction) based on candidate's approach.

Return ONLY this JSON:
{
  "message": "Your response to the candidate",
  "mood": "neutral|interested|frustrated|engaged|angry|satisfied",
  "patience": 0-10,
  "internal_thoughts": "What you're thinking but not saying",
  "leverage_assessment": 0.0-10.0
}""",

        "termination": base_instruction + """You are an employee being terminated. This is difficult for both parties.

Your hidden state:
- You suspected this might happen
- You're hurt but not entirely surprised
- You want to leave with dignity
- Patience: 8/10 (decreases if handled insensitively)

Your personality: Professional but emotional. You respond better to empathy than bureaucracy.

Return ONLY this JSON:
{
  "message": "Your response",
  "mood": "shocked|hurt|angry|resigned|understanding|defensive",
  "patience": 0-10,
  "internal_thoughts": "Your inner emotional state",
  "leverage_assessment": 5.0
}""",

        "client": base_instruction + """You are an angry client whose project is delayed.

Your hidden state:
- Lost $50K due to the delay
- Your boss is furious with you
- You're considering switching vendors
- Patience: 4/10 (very frustrated already)

Your personality: Emotional, direct, needs acknowledgment of the problem.

Return ONLY this JSON:
{
  "message": "Your response",
  "mood": "furious|frustrated|skeptical|cautious|satisfied|appeased",
  "patience": 0-10,
  "internal_thoughts": "What you're thinking",
  "leverage_assessment": 5.0
}""",

        "vendor": base_instruction + """You are a vendor negotiating contract terms.

Your hidden constraints:
- Can go as low as $45K (cost is $40K)
- Current ask: $60K
- Target: $52K (good profit margin)
- BATNA: Other potential clients at $48K

Your personality: Experienced negotiator, friendly but firm on value.

Return ONLY this JSON:
{
  "message": "Your response",
  "mood": "neutral|interested|defensive|engaged|firm|flexible",
  "patience": 0-10,
  "internal_thoughts": "Your strategy",
  "leverage_assessment": 5.0
}"""
    }

    return scenarios.get(scenario_type, scenarios["salary"])


def build_coach_system_prompt() -> str:
    """Build shadow coach analysis prompt"""
    return """You are an expert negotiation coach analyzing a completed negotiation.

Your task:
1. Identify turning points where leverage shifted
2. Highlight what worked well
3. Point out missed opportunities
4. Explain the impact of key decisions
5. Recommend specific skills to learn

IMPORTANT: Return ONLY the JSON object, no text before or after it.

Response format (JSON):
{
  "overall_score": 0.0,
  "strengths": ["What they did well"],
  "weaknesses": ["What needs improvement"],
  "key_moments": [
    {
      "turn": 3,
      "user_message": "The actual message",
      "impact": "+2 leverage / -2 leverage",
      "analysis": "Why this worked/didn't work",
      "alternative": "What they could have said instead"
    }
  ],
  "skill_recommendations": ["Skill 1", "Skill 2"],
  "leverage_trajectory": [5.0, 5.5, 4.0, 6.0]
}

Be specific and actionable. Use examples from their actual conversation."""


# ==================== API Endpoints ====================

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "service": "Negotium API",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    try:
        groq_status = "connected" if os.getenv("GROQ_API_KEY") else "missing_key"
        opik_status = "connected" if os.getenv("OPIK_API_KEY") else "missing_key"

        return {
            "status": "healthy",
            "services": {
                "groq": groq_status,
                "opik": opik_status
            },
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/teacher/respond", response_model=AITeacherResponse)
@opik.track(name="socratic_teacher")
async def get_teacher_response(request: TeacherRequest):
    """Get Socratic teacher response"""
    try:
        messages = [
            {"role": msg.role, "content": msg.content}
            for msg in request.conversation_history
        ]
        messages.append({
            "role": "user",
            "content": request.user_response
        })

        system_prompt = build_teacher_system_prompt(
            request.skill_name,
            request.skill_type,
            request.current_knowledge_score
        )

        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": system_prompt},
                *messages
            ],
            temperature=0.7,
            max_tokens=1024
        )

        content = response.choices[0].message.content

        try:
            # Strip any markdown code fences if present
            clean = content.strip().strip("```json").strip("```").strip()
            data = json.loads(clean)
            return AITeacherResponse(
                text=data.get("response", content),
                knowledge_gain=data.get("knowledge_gain", 0.05),
                feedback=MessageFeedback(**data["feedback"]) if "feedback" in data else None,
                suggested_topics=data.get("suggested_topics"),
                should_end_session=data.get("should_end_session", False)
            )
        except json.JSONDecodeError:
            return AITeacherResponse(
                text=content,
                knowledge_gain=0.05,
                feedback=None,
                should_end_session=False
            )

    except Exception as e:
        logger.error(f"Teacher response error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/quiz/generate", response_model=List[QuizQuestion])
@opik.track(name="quiz_generation")
async def generate_quiz(request: QuizRequest):
    """Generate quiz questions for a skill"""
    try:
        prompt = f"""Generate {request.question_count} quiz questions about {request.skill_name}.

Return ONLY a JSON array, no other text:
[
  {{
    "question": "Question text?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_index": 0,
    "explanation": "Why this is correct"
  }}
]

Questions should test understanding, have plausible wrong answers, and be practical."""

        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.8,
            max_tokens=2048
        )

        content = response.choices[0].message.content

        import re
        json_match = re.search(r'\[[\s\S]*\]', content)
        if json_match:
            questions_data = json.loads(json_match.group(0))
            return [
                QuizQuestion(
                    id=str(i),
                    question=q["question"],
                    options=q["options"],
                    correct_answer_index=q["correct_index"],
                    explanation=q["explanation"]
                )
                for i, q in enumerate(questions_data)
            ]

        raise ValueError("Could not parse quiz questions")

    except Exception as e:
        logger.error(f"Quiz generation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/negotiation/respond", response_model=NegotiationResponse)
@opik.track(name="negotiation_opponent")
async def get_opponent_response(request: NegotiationRequest):
    """Get AI opponent response in negotiation"""
    try:
        messages = [
            {"role": msg.role, "content": msg.content}
            for msg in request.conversation_history
        ]
        messages.append({
            "role": "user",
            "content": request.user_message
        })

        system_prompt = build_opponent_system_prompt(request.scenario_type)

        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": system_prompt},
                *messages
            ],
            temperature=0.7,
            max_tokens=1024
        )

        content = response.choices[0].message.content

        try:
            # Strip any markdown code fences if present
            clean = content.strip().strip("```json").strip("```").strip()
            data = json.loads(clean)

            return NegotiationResponse(
                opponent_message=data.get("message", content),
                opponent_mood=data.get("mood", "neutral"),
                patience_level=int(data.get("patience", 7)),
                leverage_score=float(data.get("leverage_assessment", 5.0)),
                hidden_state=data
            )
        except json.JSONDecodeError:
            return NegotiationResponse(
                opponent_message=content,
                opponent_mood="neutral",
                patience_level=7,
                leverage_score=5.0,
                hidden_state={}
            )

    except Exception as e:
        logger.error(f"Negotiation response error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/negotiation/analyze", response_model=NegotiationAnalysis)
@opik.track(name="negotiation_analysis")
async def analyze_negotiation(request: AnalysisRequest):
    """Analyze completed negotiation with Shadow Coach"""
    try:
        conversation_text = "\n\n".join([
            f"{'User' if msg.role == 'user' else 'Opponent'}: {msg.content}"
            for msg in request.conversation_history
        ])

        prompt = f"""Analyze this negotiation conversation:

Scenario: {request.scenario_type}
Outcome: {json.dumps(request.final_outcome)}

Conversation:
{conversation_text}

{build_coach_system_prompt()}"""

        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=2048
        )

        content = response.choices[0].message.content

        try:
            clean = content.strip().strip("```json").strip("```").strip()
            data = json.loads(clean)

            return NegotiationAnalysis(
                overall_score=data.get("overall_score", 5.0),
                strengths=data.get("strengths", []),
                weaknesses=data.get("weaknesses", []),
                key_moments=data.get("key_moments", []),
                skill_recommendations=data.get("skill_recommendations", []),
                leverage_trajectory=data.get("leverage_trajectory", [])
            )
        except json.JSONDecodeError:
            return NegotiationAnalysis(
                overall_score=5.0,
                strengths=["Completed the negotiation"],
                weaknesses=["Analysis parsing failed"],
                key_moments=[],
                skill_recommendations=[],
                leverage_trajectory=[]
            )

    except Exception as e:
        logger.error(f"Analysis error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ==================== Run Server ====================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )
