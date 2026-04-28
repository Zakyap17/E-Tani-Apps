export function classifyWeather(data) {
  const { conditionText, precip, temp } = data;
  const condition = conditionText.toLowerCase();

  let label = "Cerah";
  let recommendation = {
    action: "Siram normal",
    frequency: 1,
    interval_hours: 24,
    note: "Lakukan penyiraman rutin sesuai jadwal"
  };

  if (precip > 5 || condition.includes("heavy rain") || condition.includes("moderate rain")) {
    label = "Hujan Lebat";
    recommendation = {
      action: "Tunda penyiraman, periksa drainase",
      frequency: 2,
      interval_hours: 12,
      note: "Pastikan saluran air lancar agar tanaman tidak tergenang"
    };
  } else if (precip > 1 || condition.includes("rain")) {
    label = "Hujan Sedang";
    recommendation = {
      action: "Kurangi penyiraman",
      frequency: 1,
      interval_hours: 24,
      note: "Cek kelembapan tanah sebelum menyiram"
    };
  } else if (precip > 0 || condition.includes("drizzle") || condition.includes("patchy rain")) {
    label = "Gerimis";
    recommendation = {
      action: "Siram secukupnya",
      frequency: 1,
      interval_hours: 24,
      note: "Pantau kondisi daun untuk mencegah jamur"
    };
  } else if (temp > 32) {
    label = "Panas Terik";
    recommendation = {
      action: "Siram 2x sehari",
      frequency: 2,
      interval_hours: 12,
      note: "Siram pada pagi dan sore hari agar tidak layu"
    };
  }

  return { label, recommendation };
}

export function generateMultiDayInsight(forecastArray) {
  let insight = "Kondisi cuaca terpantau aman";
  let action_plan = "Ikuti rekomendasi harian";

  if (!forecastArray || forecastArray.length < 2) return { insight, action_plan };

  const labels = forecastArray.map(f => f.weather);
  const isHujan = (label) => label.includes("Hujan") || label === "Gerimis";

  let consecutiveHeavyRain = false;
  for (let i = 0; i < labels.length - 1; i++) {
    if (labels[i] === "Hujan Lebat" && labels[i + 1] === "Hujan Lebat") {
      consecutiveHeavyRain = true;
      break;
    }
  }

  const todayRainTomorrowHot = isHujan(labels[0]) && labels[1] === "Panas Terik";
  const hotDays = labels.filter(l => l === "Panas Terik").length;

  if (consecutiveHeavyRain) {
    insight = "Hujan akan berlangsung beberapa hari ke depan";
    action_plan = "Tunda penyiraman selama 2 hari";
  } else if (todayRainTomorrowHot) {
    insight = "Cuaca akan berubah menjadi panas";
    action_plan = "Hari ini tidak perlu penyiraman, lakukan penyiraman normal besok";
  } else if (hotDays >= 2) {
    insight = "Cuaca panas berlanjut";
    action_plan = "Lakukan penyiraman 2x sehari selama 2 hari";
  }

  return { insight, action_plan };
}
