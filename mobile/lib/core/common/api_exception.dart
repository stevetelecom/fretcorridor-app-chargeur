/// Leve cote client quand une validation locale echoue avant meme d'appeler
/// l'API (ex: draft incomplet) - distincte d'une erreur reseau/serveur pour
/// que l'UI puisse afficher un message different des erreurs Dio.
class DraftIncompleteException implements Exception {
  const DraftIncompleteException();
}
