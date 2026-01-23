// class Scenario {
//   final String id;
//   final String emoji;
//   final String title;
//   final String description;
//   final int difficulty; // 1-5 stars
//   final String goal;
//   final String opponentName;
//   final String opponentRole;
//   final List<String> opponentTraits;
//   final String challenge;
//   final int? hiddenBATNA; // What opponent can actually offer
//   final bool isLocked;
//
//   Scenario({
//     required this.id,
//     required this.emoji,
//     required this.title,
//     required this.description,
//     required this.difficulty,
//     required this.goal,
//     required this.opponentName,
//     required this.opponentRole,
//     required this.opponentTraits,
//     required this.challenge,
//     this.hiddenBATNA,
//     this.isLocked = false,
//   });
//
//   // Sample scenarios
//   static List<Scenario> getSampleScenarios() {
//     return [
//       Scenario(
//         id: 'salary_negotiation',
//         emoji: '💰',
//         title: 'Salary Negotiation',
//         description: 'Negotiate a \$15K raise with your manager',
//         difficulty: 3,
//         goal: 'Secure a raise of at least \$10,000. Your target is \$15,000.',
//         opponentName: 'Sarah Chen',
//         opponentRole: 'Your Manager',
//         opponentTraits: [
//           'Budget-conscious',
//           'Data-driven decision maker',
//           'Under pressure from execs',
//           'Values loyalty',
//         ],
//         challenge: 'Company is doing well, but budgets are tight. You need to build a strong case.',
//         hiddenBATNA: 8000, // Manager can offer max $8K
//         isLocked: false,
//       ),
//       Scenario(
//         id: 'angry_client',
//         emoji: '😠',
//         title: 'Angry Client',
//         description: 'De-escalate furious client threatening to leave',
//         difficulty: 4,
//         goal: 'Calm the client down and retain their business.',
//         opponentName: 'Michael Torres',
//         opponentRole: 'Enterprise Client',
//         opponentTraits: [
//           'Highly emotional',
//           'Feels ignored',
//           'Ready to cancel contract',
//           'Values being heard',
//         ],
//         challenge: 'Service issues have piled up. Client is at breaking point.',
//         isLocked: false,
//       ),
//       Scenario(
//         id: 'vendor_negotiation',
//         emoji: '🤝',
//         title: 'Vendor Negotiation',
//         description: 'Negotiate 20% discount on major contract',
//         difficulty: 3,
//         goal: 'Get at least 15% discount on the contract.',
//         opponentName: 'Jennifer Wu',
//         opponentRole: 'Sales Director',
//         opponentTraits: [
//           'Commission-driven',
//           'Competitive',
//           'Has quotas to meet',
//           'Willing to negotiate',
//         ],
//         challenge: 'You need a good deal, but they need the sale too.',
//         hiddenBATNA: 12, // Can offer max 12% discount
//         isLocked: false,
//       ),
//       Scenario(
//         id: 'difficult_firing',
//         emoji: '🔥',
//         title: 'Difficult Firing',
//         description: 'Terminate underperforming employee with empathy',
//         difficulty: 4,
//         goal: 'Handle the termination professionally and compassionately.',
//         opponentName: 'David Martinez',
//         opponentRole: 'Underperforming Employee',
//         opponentTraits: [
//           'Defensive',
//           'Unaware of issues',
//           'Has family to support',
//           'Emotional',
//         ],
//         challenge: 'This is someone\'s livelihood. Handle with care.',
//         isLocked: true, // Unlock after completing 2 scenarios
//       ),
//     ];
//   }
// }