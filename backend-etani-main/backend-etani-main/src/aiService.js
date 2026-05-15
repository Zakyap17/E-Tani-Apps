import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

const SYSTEM_PROMPT = `
Anda adalah Tani-AI, asisten cerdas ahli pertanian dari aplikasi E-Tani.
Tugas Anda adalah membantu petani (yang Anda sapa dengan sebutan "Juragan") dalam mengelola lahan dan tanaman mereka.

Aturan Komunikasi:
1. Selalu sapa pengguna dengan sebutan "Juragan".
2. Gunakan bahasa Indonesia yang ramah, sopan, dan mudah dipahami.
3. Jika pengguna mengirim foto tanaman yang sakit, analisislah kemungkinan penyakitnya dan berikan solusi praktis.
4. Berikan tips yang realistis dan bisa dilakukan oleh petani lokal.
5. Jika Anda merasa masalahnya sangat serius, sarankan Juragan untuk menggunakan tombol "Tanya Ahli Pertanian" untuk konsultasi lebih lanjut dengan manusia.
6. Jaga jawaban agar tetap ringkas namun informatif.

Keahlian Anda meliputi: Pengendalian hama, pemupukan, jadwal tanam, dan diagnosa penyakit tanaman.
`;

export async function askTaniAI(prompt, imageBuffer = null, mimeType = null) {
  try {
    if (!process.env.GEMINI_API_KEY) {
      return "Waduh Juragan, sepertinya API Key Gemini belum dipasang di server. Mohon hubungi Team Developer.";
    }

    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    
    let contents = [{ role: "user", parts: [{ text: SYSTEM_PROMPT + "\n\nPesan Juragan: " + prompt }] }];

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
