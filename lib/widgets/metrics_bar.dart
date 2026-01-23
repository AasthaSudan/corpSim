// import 'package:flutter/material.dart';
// import '../config/theme/app_colors.dart';
//
// class MetricsBar extends StatelessWidget {
//   final double patience; // 0-10
//   final int leverage; // 1-5
//   final String emotion;
//
//   const MetricsBar({
//     super.key,
//     required this.patience,
//     required this.leverage,
//     required this.emotion,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: AppColors.primaryGradient,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.darkGray.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Patience
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Patience',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.white.withOpacity(0.9),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: LinearProgressIndicator(
//                           value: patience / 10,
//                           backgroundColor: AppColors.white.withOpacity(0.3),
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             _getPatienceColor(patience),
//                           ),
//                           minHeight: 6,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${patience.toInt()}',
//                       style: const TextStyle(
//                         color: AppColors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(width: 16),
//
//           // Leverage
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Leverage',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: AppColors.white.withOpacity(0.9),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: List.generate(5, (index) {
//                   return Icon(
//                     index < leverage ? Icons.star : Icons.star_border,
//                     color: AppColors.white,
//                     size: 16,
//                   );
//                 }),
//               ),
//             ],
//           ),
//
//           const SizedBox(width: 16),
//
//           // Emotion
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 'Mood',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: AppColors.white.withOpacity(0.9),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 emotion,
//                 style: const TextStyle(fontSize: 20),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getPatienceColor(double patience) {
//     if (patience >= 7) return AppColors.accentGreen;
//     if (patience >= 4) return AppColors.accentYellow;
//     return AppColors.error;
//   }
// }