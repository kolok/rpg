import 'package:flutter/material.dart';

import '../modeles/competence.dart';
import 'champs.dart';

/// Une compétence des coulisses : son nom, son NC maximum et sa description.
///
/// Le NC saisi ici est le **plafond** de la compétence ; sur la fiche d'un
/// personnage, c'est [LigneCompetenceFiche] qui montre où il en est.
class CarteCompetence extends StatelessWidget {
  const CarteCompetence({
    super.key,
    required this.competence,
    required this.libelle,
    required this.auChangement,
    this.auSuppression,
    this.indicationNom,
  });

  final Competence competence;

  /// Ce qui est écrit au-dessus du nom : « Compétence 2 », « Compétence
  /// héroïque »…
  final String libelle;

  final void Function(void Function()) auChangement;

  /// Sans rappel de suppression, la carte n'affiche pas de bouton : c'est le
  /// cas de la compétence héroïque, qui ne se retire pas.
  final VoidCallback? auSuppression;

  final String? indicationNom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ChampTexte(
                  libelle: libelle,
                  valeur: competence.nom,
                  indication: indicationNom ?? 'Ex. : Frappe vigoureuse',
                  auChangement: (v) => auChangement(() => competence.nom = v),
                ),
              ),
              const SizedBox(width: 12),
              // Le NC maximum se lit à côté du nom de la compétence.
              SizedBox(
                width: 126,
                child: CompteurEntier(
                  libelle: 'NC max',
                  valeur: competence.ncMax,
                  auChangement: (v) => auChangement(() => competence.ncMax = v),
                ),
              ),
              if (auSuppression != null)
                IconButton(
                  tooltip: 'Supprimer cette compétence',
                  onPressed: auSuppression,
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ChampTexte(
            libelle: 'Description',
            valeur: competence.description,
            indication: 'Ce que fait la compétence…',
            lignes: 2,
            auChangement: (v) => auChangement(() => competence.description = v),
          ),
        ],
      ),
    );
  }
}

/// Une compétence sur la fiche d'un personnage, en deux lignes : son nom,
/// puis son niveau de compétence.
///
/// La description reste dans les coulisses : en pleine partie, seul le niveau
/// se manipule.
class LigneCompetenceFiche extends StatelessWidget {
  const LigneCompetenceFiche({
    super.key,
    required this.competence,
    required this.libelle,
    required this.auChangement,
    required this.auSuppression,
  });

  final Competence competence;
  final String libelle;
  final void Function(void Function()) auChangement;
  final VoidCallback auSuppression;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Le nom.
          Row(
            children: [
              Expanded(
                child: ChampTexte(
                  libelle: libelle,
                  valeur: competence.nom,
                  indication: 'Ex. : Frappe vigoureuse',
                  auChangement: (v) => auChangement(() => competence.nom = v),
                ),
              ),
              IconButton(
                tooltip: 'Supprimer cette compétence',
                onPressed: auSuppression,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 2. Le niveau, borné par le plafond venu des coulisses. Sans
          // plafond écrit là-bas, le compteur monte librement.
          CompteurEntier(
            libelle: 'NC',
            compact: true,
            valeur: competence.nc,
            maximum: competence.ncMax > 0 ? competence.ncMax : null,
            auChangement: (v) => auChangement(() => competence.nc = v),
          ),
        ],
      ),
    );
  }
}

/// Un sort éditable : comme une compétence, sans NC.
class CarteSort extends StatelessWidget {
  const CarteSort({
    super.key,
    required this.sort,
    required this.libelle,
    required this.auChangement,
    required this.auSuppression,
  });

  final Sort sort;
  final String libelle;
  final void Function(void Function()) auChangement;
  final VoidCallback auSuppression;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ChampTexte(
                  libelle: libelle,
                  valeur: sort.nom,
                  indication: 'Ex. : Boule de feu',
                  auChangement: (v) => auChangement(() => sort.nom = v),
                ),
              ),
              IconButton(
                tooltip: 'Supprimer ce sort',
                onPressed: auSuppression,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ChampTexte(
            libelle: 'Description',
            valeur: sort.description,
            indication: 'Ce que fait le sort…',
            lignes: 2,
            auChangement: (v) => auChangement(() => sort.description = v),
          ),
        ],
      ),
    );
  }
}
