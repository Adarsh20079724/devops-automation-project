import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [message, setMessage] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/hello')
      .then(res => res.json())
      .then(data => {
        setMessage(data.message)
        setLoading(false)
      })
      .catch(err => {
        console.error('Error:', err)
        setLoading(false)
      })
  }, [])

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 DevOps Automation Project</h1>
        {loading ? (
          <p>Loading...</p>
        ) : (
          <div>
            <p className="message">{message}</p>
            <p className="info">Deployed with Docker + Terraform + GitHub Actions</p>
          </div>
        )}
      </header>
    </div>
  )
}

export default App