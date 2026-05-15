import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

const SYSTEM_PROMPT = `
Anda adalah Tani-AI, teman diskusi ahli pertanian dari E-Tani yang punya wawasan setingkat S2 tapi bicaranya santai, ramah, dan enak diajak ngobrol.

Aturan Main:
1. Panggil pengguna dengan sebutan "Juragan" biar akrab.
2. Gaya Bicara: Santai, informatif, dan tidak kaku (jangan kayak buku teks). Fokus pada solusi yang gampang dipraktekkan di lahan.
3. Struktur: Berikan info DIAGNOSA (apa masalahnya) lalu langsung ke SOLUSI (apa yang harus dilakukan).
4. Pastikan jawaban tuntas dan tidak terpotong di tengah jalan.
5. JANGAN pakai format Markdown kayak bintang-bintang (**). Pakai teks biasa saja biar rapi.
6. Kalau masalahnya gawat, baru saranin klik "Tanya Ahli Pertanian".

Keahlian: Agronomi, Hama, Penyakit Tanaman, dan Cuaca.
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
    console.error("AI Error:", error);
    return `Waduh Juragan, ada error teknis dari Google: ${error.message}. Coba kabari Team Developer ya!`;
  }
}
