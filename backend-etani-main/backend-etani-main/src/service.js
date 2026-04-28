import { classifyWeather, generateMultiDayInsight } from './classifier.js';

export async function getTodayData(city) {
  const locationQuery = city || process.env.DEFAULT_CITY || "Bandung";
  const apiKey = process.env.WEATHER_API_KEY || "YOUR_API_KEY";
  const baseUrl = process.env.WEATHER_BASE_URL || "http://api.weatherapi.com/v1";
  
  const url = `${baseUrl}/forecast.json?key=${apiKey}&q=${encodeURIComponent(locationQuery)}&days=3`;

  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Weather API returned status ${response.status}`);
    }
    
    const data = await response.json();
    
    const dayLabels = ["Hari Ini", "Besok", "Lusa"];
    const forecastArray = [];
    let currentRecommendation;

    data.forecast.forecastday.forEach((dayData, index) => {
      if (index > 2) return; // Safeguard to strictly process 3 days

      const temp = dayData.day.avgtemp_c;
      const precip = dayData.day.totalprecip_mm;
      const conditionText = dayData.day.condition.text;

      const classification = classifyWeather({ conditionText, precip, temp });

      if (index === 0) {
        currentRecommendation = classification.recommendation;
      }

      forecastArray.push({
        day: dayLabels[index],
        weather: classification.label,
        temperature: temp
      });
    });

    const multiDayInsight = generateMultiDayInsight(forecastArray);

    return {
      location: data.location.name,
      insight: multiDayInsight.insight,
      action_plan: multiDayInsight.action_plan,
      current: {
        temperature: forecastArray[0].temperature,
        weather: forecastArray[0].weather
      },
      recommendation: currentRecommendation,
      forecast: forecastArray
    };
  } catch (error) {
    console.error("Error fetching weather data:", error.message);
    throw new Error("Failed to retrieve weather data");
  }
}
