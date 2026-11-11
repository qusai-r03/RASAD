import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// المساعدة والدعم: أسئلة شائعة.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(context.tr('helpTitle'))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          for (var i = 1; i <= 4; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: AppDecor.card(radius: 14),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(context.tr('faq${i}q'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('faq${i}a'), style: const TextStyle(color: AppColors.muted, height: 1.5)),
                  ],
                ),
              ),
            ),
        ]),
      );
}
