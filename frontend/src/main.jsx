import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import RadarProvider from './store.jsx'
import SiteGate from './SiteGate.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <SiteGate>
      <RadarProvider>
        <App />
      </RadarProvider>
    </SiteGate>
  </StrictMode>,
)
