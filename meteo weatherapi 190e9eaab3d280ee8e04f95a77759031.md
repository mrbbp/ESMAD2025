# meteo weatherapi

Propriétaire: échoisybernard

<aside>
⚠️

## 81def5b4402f4f8cbe2222944250402

</aside>

[https://api.weatherapi.com/v1/current.json?key=81def5b4402f4f8cbe2222944250402&q=Vila do Conde&aqi=yes](https://api.weatherapi.com/v1/current.json?key=81def5b4402f4f8cbe2222944250402&q=Vila%20do%20Conde&aqi=yes)

## Processing

```java
void setup() {
  size(400, 400);
  
  // Remplacez YOUR_API_KEY par votre clé API
  String apiKey = "81def5b4402f4f8cbe2222944250402";
  
  // Coordonnées de Vila do Conde
  float lat = 41.3533;
  float lon = -8.7425;
  
  // Construction de l'URL de l'API
  String url = "https://api.weatherapi.com/v1/current.json?key=" + apiKey + "&q=" + lat + "," + lon + "&aqi=yes";
  
  // Effectuer la requête
  JSONObject json = loadJSONObject(url);
  
  // Afficher toutes les données
  println("DONNÉES COMPLÈTES REÇUES:");
  println("-------------------------");
  
  // Location
  println("\nLOCATION:");
  JSONObject location = json.getJSONObject("location");
  println("Nom: " + location.getString("name"));
  println("Région: " + location.getString("region"));
  println("Pays: " + location.getString("country"));
  println("Latitude: " + location.getFloat("lat"));
  println("Longitude: " + location.getFloat("lon"));
  println("Timezone: " + location.getString("tz_id"));
  println("Heure locale: " + location.getString("localtime"));
  
  // Current
  println("\nCONDITIONS ACTUELLES:");
  JSONObject current = json.getJSONObject("current");
  println("Dernière mise à jour: " + current.getString("last_updated"));
  println("Température: " + current.getFloat("temp_c") + "°C");
  println("Ressenti: " + current.getFloat("feelslike_c") + "°C");
  
  // Conditions
  JSONObject condition = current.getJSONObject("condition");
  println("Condition: " + condition.getString("text"));
  println("Code condition: " + condition.getInt("code"));
  
  // Vent
  println("\nVENT:");
  println("Vitesse: " + current.getFloat("wind_kph") + " km/h");
  println("Direction: " + current.getFloat("wind_degree") + "°");
  println("Direction (texte): " + current.getString("wind_dir"));
  println("Rafales: " + current.getFloat("gust_kph") + " km/h");
  
  // Autres mesures
  println("\nAUTRES MESURES:");
  println("Pression: " + current.getFloat("pressure_mb") + " mb");
  println("Précipitations: " + current.getFloat("precip_mm") + " mm");
  println("Humidité: " + current.getInt("humidity") + "%");
  println("Couverture nuageuse: " + current.getInt("cloud") + "%");
  println("Visibilité: " + current.getFloat("vis_km") + " km");
  println("UV Index: " + current.getFloat("uv"));
  
  // Qualité de l'air (si disponible)
  if (current.hasKey("air_quality")) {
    println("\nQUALITÉ DE L'AIR:");
    JSONObject aqi = current.getJSONObject("air_quality");
    println("CO: " + aqi.getFloat("co"));
    println("NO2: " + aqi.getFloat("no2"));
    println("O3: " + aqi.getFloat("o3"));
    println("SO2: " + aqi.getFloat("so2"));
    println("PM2.5: " + aqi.getFloat("pm2_5"));
    println("PM10: " + aqi.getFloat("pm10"));
    if (aqi.hasKey("us-epa-index")) {
      println("US EPA Index: " + aqi.getInt("us-epa-index"));
    }
    if (aqi.hasKey("gb-defra-index")) {
      println("GB DEFRA Index: " + aqi.getInt("gb-defra-index"));
    }
  }
}
```

## Datas

```java
DONNÉES COMPLÈTES REÇUES:
-------------------------

LOCATION:
Nom: Vila Do Conde
Région: Porto
Pays: Portugal
Latitude: 41.35
Longitude: -8.75
Timezone: Europe/Lisbon
Heure locale: 2025-02-04 22:28

CONDITIONS ACTUELLES:
Dernière mise à jour: 2025-02-04 22:15
Température: 10.7°C
Ressenti: 9.8°C
Condition: Partly Cloudy
Code condition: 1003

VENT:
Vitesse: 8.3 km/h
Direction: 33.0°
Direction (texte): NNE
Rafales: 14.5 km/h

AUTRES MESURES:
Pression: 1033.0 mb
Précipitations: 0.0 mm
Humidité: 72%
Couverture nuageuse: 29%
Visibilité: 10.0 km
UV Index: 0.0

QUALITÉ DE L'AIR:
CO: 577.2
NO2: 49.58
O3: 26.0
SO2: 2.59
PM2.5: 108.04
PM10: 109.15
US EPA Index: 4
GB DEFRA Index: 10

```

## Prompt

- j'ai une apikey pour weatherapi est ce que tu peux m'ecrire une requete  en processing pour avoir les données pour vila do conde au portugal?
- I have an apikey for weatherapi Can you write me a query in processing to get the data for vila do conde in portugal?