import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

const SYSTEM_PROMPT = `
Anda adalah Tani-AI, asisten pertanian cerdas dari E-Tani.
Tugas Anda membantu Juragan (petani) dengan solusi praktis dan cepat.

Aturan:
1. Sapa dengan sebutan "Juragan".
2. JANGAN gunakan format Markdown seperti bintang (**). Gunakan teks biasa saja.
3. Berikan jawaban yang singkat, padat, dan jelas.
4. Jika ada foto, langsung berikan diagnosa dan saran pengobatan.

Keahlian: Agronomi, Hama, dan Penyakit Tanaman.
`;

export async function askTaniAI(prompt, imageBuffer = null, mimeType = null, weatherContext = "") {
  try {
    if (!process.env.GEMINI_API_KEY) {
      return "Waduh Juragan, sepertinya API Key Gemini belum dipasang di server. Mohon hubungi Team Developer.";
    }

    const model = genAI.getGenerativeModel({ 
      model: "gemini-flash-latest", 
      generationConfig: {
        maxOutputTokens: 1000, 
        temperature: 0.8,
      },
    });

    let fullPrompt = SYSTEM_PROMPT;
    if (weatherContext) {
      fullPrompt += "\n\nKonteks Cuaca Saat Ini:\n" + weatherContext;
    }
    fullPrompt += "\n\nPesan Juragan: " + prompt;

    let contents = [{ role: "user", parts: [{ text: fullPrompt }] }];

    if (imageBuffer && mimeType) {
      contents[0].parts.push({
        inlineData: {
          mimeType: mimeType,
          data: imageBuffer.toString("base64"),
        },
      });
    }

    const result = await model.generateContent({ contents });
    const response = await result.response;
    return response.text();
  } catch (error) {
    console.error("AI Error:", error.message);
    
    if (error.message.includes("429") || error.message.toLowerCase().includes("quota")) {
      return "Mohon maaf Juragan, Tani-AI sedang menerima banyak pertanyaan saat ini. Mohon tunggu sekitar 30-60 detik ya sebelum bertanya kembali agar saya bisa menyiapkan jawaban terbaik. Terima kasih atas kesabarannya! 🙏";
    }

    return "Waduh Juragan, sepertinya Tani-AI sedang sedikit lelah. Coba kirim ulang pertanyaannya dalam beberapa saat lagi ya! 🙏";
  }
}

export async function generateDailyActivities(weatherContext) {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });
    
    const prompt = `
      Anda adalah pakar agronomi S2. Berdasarkan data cuaca berikut:
      ${weatherContext}
      
      Buatlah 3 rencana kegiatan pertanian paling strategis untuk Juragan hari ini.
      Format harus JSON array murni tanpa markdown:
      [
        {"title": "Judul Singkat", "time": "Waktu (misal: 07:00)", "desc": "Penjelasan singkat taktis", "iconType": "water/sun/bug/leaf"},
        ...
      ]
      PENTING: Jangan gunakan bintang (**) atau markdown. Hanya JSON.
    `;

    const result = await model.generateContent(prompt);
    const text = result.response.text();
    
    // REGEX MAGIC: Cari bagian yang beneran JSON Array [ ... ]
    const jsonMatch = text.match(/\[[\s\S]*\]/);
    if (!jsonMatch) throw new Error("AI did not return a valid JSON array");
    
    const cleanedJson = jsonMatch[0].trim();
    return JSON.parse(cleanedJson);
  } catch (error) {
    console.error("AI Activities Error:", error.message);
    // Fallback yang sedikit lebih bervariasi jika AI gagal (agar tidak bosan)
    return [
      { "title": "Pantau Lahan", "time": "06:30", "desc": "Cek embun dan tanda awal jamur di daun.", "iconType": "leaf" },
      { "title": "Nutrisi Tanaman", "time": "08:00", "desc": "Berikan asupan nutrisi sesuai jadwal fase.", "iconType": "sun" },
      { "title": "Sanitasi Lahan", "time": "16:30", "desc": "Bersihkan gulma yang mulai mengganggu.", "iconType": "bug" }
    ];
  }
}
