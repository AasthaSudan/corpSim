import requests

BASE_URL = "http://localhost:8000"

def test_health():
    print("Testing health check...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Backend is online!")
            print(f"  Groq: {data['services']['groq']}")
            print(f"  Opik: {data['services']['opik']}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Cannot connect: {e}")
        return False

if __name__ == "__main__":
    test_health()
