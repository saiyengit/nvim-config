-- Palette tirée de la photo du fond d'écran (~/42/divers/fond/fond.jpg) :
-- un coucher de soleil rouge et rose sur la mer, sous un ciel bleu nuit.
--
-- Une couleur = un rôle dans le code (voir lua/plugins/ui.lua) :
--   rose     mots-clés, #include      if while return static struct typedef
--   lavande  types                    int char void size_t t_list s_list
--   ciel     fonctions                ft_lstnew malloc write (définition et appel)
--   peche    paramètres               lst, del, f dans la fonction qui les reçoit
--   blanc    variables et champs      temp, i, list->next, list->content
--   poudre   opérateurs               * & -> = + ++ !
--   dore     chaînes et caractères    "abc" 'c' <stdio.h>
--   ecume    valeurs fixes            42 NULL '\0' BUFFER_SIZE \n
--   mauve    commentaires             l'en-tête 42
--
-- Toutes les couleurs du texte sont claires pour rester lisibles même sur les
-- nuages lumineux du fond : contraste vérifié d'au moins 4,5:1 sur 90 % de
-- l'image (les commentaires, plus discrets exprès : 3,4:1).

return {
  -- texte
  rose = "#ff94c8", -- reflets roses des nuages
  lavande = "#c8b0ff", -- soleil magenta, adouci
  ciel = "#92c8ff", -- nuages gris-bleu
  peche = "#ffaa8a", -- reflets chauds sur l'eau
  blanc = "#f5e6ea", -- blanc rosé du centre du ciel
  poudre = "#f0b8c8", -- rose poudré
  dore = "#f8cf8f", -- lumière du soleil couchant
  ecume = "#9fe3dc", -- écume des vagues
  gris = "#cbb4bd", -- ponctuation ; ,
  mauve = "#ad95a3", -- nuages sombres
  numeros = "#86c4bd", -- numéros de ligne
  erreur = "#ff8095",

  -- fonds opaques : sélection, menus, barre du bas
  vin = "#5b2445",
  vin_fonce = "#3a1626",
  nuit = "#170f16",
  encre = "#1a0d14", -- texte posé sur une pastille colorée
}
