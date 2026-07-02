import { DownloadCTA } from './sections/DownloadCTA'
import { Features } from './sections/Features'
import { Footer } from './sections/Footer'
import { Header } from './sections/Header'
import { Hero } from './sections/Hero'
import { Showcase } from './sections/Showcase'

function App() {
  return (
    <div className="min-h-screen overflow-hidden bg-[#05070d] text-white">
      <Header />
      <main>
        <Hero />
        <Showcase />
        <Features />
        <DownloadCTA />
      </main>
      <Footer />
    </div>
  )
}

export default App
