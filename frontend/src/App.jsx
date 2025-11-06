import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [currentTime, setCurrentTime] = useState('')

  useEffect(() => {
    // Update time every second
    const timer = setInterval(() => {
      setCurrentTime(new Date().toLocaleString())
    }, 1000)

    return () => clearInterval(timer)
  }, [])

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 DevOps Automation Project</h1>
        <div>
          <p className="message">Hello World from DevOps! 🌍</p>
          <p className="info">Deployed with Docker + Terraform + GitHub Actions + Nginx</p>
          <p className="time">Current Time: {currentTime}</p>
        </div>
      </header>
    </div>
  )
}

export default App