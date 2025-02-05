# meteo openweather

Propriétaire: échoisybernard

# API Key :

<aside>
⚠️

## c8488c3575efedf39b2496bc9ecc4af0

</aside>

## Processing

```java
void setup() {
  size(400, 400);
  
  // Remplacez YOUR_API_KEY par votre clé API
  //String apiKey = "YOUR_API_KEY";
  String apiKey = "c8488c3575efedf39b2496bc9ecc4af0";
  
 // Coordonnées de Vila do Conde
  float lat = 41.3533;
  float lon = -8.7425;
  
  // Construction de l'URL de l'API
  String url = "http://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&appid=" + apiKey + "&units=metric";
  
  // Effectuer la requête
  JSONObject json = loadJSONObject(url);
  
  // Afficher toutes les données brutes
  println("DONNÉES COMPLÈTES REÇUES:");
  println("-------------------------");
  
  // Coordonnées
  println("\nCOORDONNÉES:");
  JSONObject coord = json.getJSONObject("coord");
  println("Latitude: " + coord.getFloat("lat"));
  println("Longitude: " + coord.getFloat("lon"));
  
  // Weather (conditions météo)
  println("\nCONDITIONS MÉTÉO:");
  JSONArray weather = json.getJSONArray("weather");
  for (int i = 0; i < weather.size(); i++) {
    JSONObject w = weather.getJSONObject(i);
    println("ID: " + w.getInt("id"));
    println("Principal: " + w.getString("main"));
    println("Description: " + w.getString("description"));
    println("Icône: " + w.getString("icon"));
  }
  
  // Main (données principales)
  println("\nDONNÉES PRINCIPALES:");
  JSONObject main = json.getJSONObject("main");
  println("Température: " + main.getFloat("temp") + "°C");
  println("Ressenti: " + main.getFloat("feels_like") + "°C");
  println("Température min: " + main.getFloat("temp_min") + "°C");
  println("Température max: " + main.getFloat("temp_max") + "°C");
  println("Pression: " + main.getInt("pressure") + " hPa");
  println("Humidité: " + main.getInt("humidity") + "%");
  
  // Vent
  println("\nVENT:");
  JSONObject wind = json.getJSONObject("wind");
  println("Vitesse: " + wind.getFloat("speed") + " m/s");
  if (wind.hasKey("deg")) println("Direction: " + wind.getFloat("deg") + "°");
  if (wind.hasKey("gust")) println("Rafales: " + wind.getFloat("gust") + " m/s");
  
  // Nuages
  println("\nNUAGES:");
  println("Couverture: " + json.getJSONObject("clouds").getInt("all") + "%");
  
  // Pluie (si présent)
  if (json.hasKey("rain")) {
    println("\nPLUIE:");
    JSONObject rain = json.getJSONObject("rain");
    if (rain.hasKey("1h")) println("Dernière heure: " + rain.getFloat("1h") + " mm");
    if (rain.hasKey("3h")) println("Dernières 3 heures: " + rain.getFloat("3h") + " mm");
  }
  
  // Neige (si présent)
  if (json.hasKey("snow")) {
    println("\nNEIGE:");
    JSONObject snow = json.getJSONObject("snow");
    if (snow.hasKey("1h")) println("Dernière heure: " + snow.getFloat("1h") + " mm");
    if (snow.hasKey("3h")) println("Dernières 3 heures: " + snow.getFloat("3h") + " mm");
  }
  
  // Données système
  println("\nSYSTÈME:");
  JSONObject sys = json.getJSONObject("sys");
  println("Pays: " + sys.getString("country"));
  println("Lever du soleil: " + timestampToTime(sys.getLong("sunrise")));
  println("Coucher du soleil: " + timestampToTime(sys.getLong("sunset")));
  
  // Informations générales
  println("\nINFORMATIONS GÉNÉRALES:");
  println("ID ville: " + json.getInt("id"));
  println("Nom: " + json.getString("name"));
  println("Timezone: " + json.getInt("timezone") + " (décalage en secondes par rapport à UTC)");
  println("Date/heure mesure: " + timestampToTime(json.getLong("dt")));
}

String timestampToTime(long timestamp) {
  java.util.Date date = new java.util.Date(timestamp * 1000L);
  java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("HH:mm");
  return sdf.format(date);
}
```

## Data

```
DONNÉES COMPLÈTES REÇUES:
-------------------------

COORDONNÉES:
Latitude: 41.3533
Longitude: -8.7425

CONDITIONS MÉTÉO:
ID: 803
Principal: Clouds
Description: broken clouds
Icône: 04n

DONNÉES PRINCIPALES:
Température: 7.26°C
Ressenti: 7.26°C
Température min: 7.26°C
Température max: 8.33°C
Pression: 1033 hPa
Humidité: 87%

VENT:
Vitesse: 0.0 m/s
Direction: 0.0°

NUAGES:
Couverture: 61%

SYSTÈME:
Pays: PT
Lever du soleil: 07:43
Coucher du soleil: 17:54

INFORMATIONS GÉNÉRALES:
ID ville: 2732649
Nom: Vila do Conde
Timezone: 0 (décalage en secondes par rapport à UTC)
Date/heure mesure: 22:10
```

## Prompt

- j'ai une apikey pour openweathermap. est ce que tu peux m'ecrire une requete  en processing pour avoir les données pour vila do conde au portugal?
- I have an apikey for openweathermap. Can you write me a query in processing to get the data for vila do conde in portugal?