import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const PRODUCTION_API_BASE = 'https://ipo-radar-backend.vercel.app'

export default defineConfig(({ mode }) => ({
  plugins: [react()],
  define: {
    'import.meta.env.VITE_API_BASE_URL': JSON.stringify(
      mode === 'production'
        ? PRODUCTION_API_BASE
        : process.env.VITE_API_BASE_URL || ''
    )
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8787',
        changeOrigin: true,
      },
    },
  },
}))
