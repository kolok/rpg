import 'package:flutter/material.dart';

import 'ecrans/accueil.dart';
import 'modeles/bibliotheque.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bibliotheque = await Bibliotheque.charger();
  runApp(ApplicationRpg(bibliotheque: bibliotheque));
}

class ApplicationRpg extends StatelessWidget {
  const ApplicationRpg({super.key, required this.bibliotheque});

  final Bibliotheque bibliotheque;

  @override
  Widget build(BuildContext context) {
    return BibliothequeScope(
      bibliotheque: bibliotheque,
      child: MaterialApp(
        title: 'RPG - fiches de personnage et lancer de dés',
        debugShowCheckedModeBanner: false,
        theme: themeClair(),
        darkTheme: themeSombre(),
        home: const EcranAccueil(),
      ),
    );
  }
}
