import React, { useEffect, useState } from 'react'

const App = () => {
  const [message, setMessage] = useState('Loading...')
  const [count, setCount] = useState(0)

  useEffect(() => {
    // Fetch message from backend
    fetch('/api/hello')
      .then(response => response.json())
      .then(data => setMessage(data.message))
      .catch(error => {
        console.error('Error:', error)
        setMessage('Error connecting to backend')
      })
  }, [])

  return (
    <div className="App">
      <div className="card">
        <h1>Hello World DevOps Project</h1>
        <p className="message">{message}</p>
        <div className="counter">
          <button onClick={() => setCount(count + 1)}>
            Count is: {count}
          </button>
        </div>
        <div className="tech-stack">
          <h3>Tech Stack:</h3>
          <ul>
            <li>⚛️ React + Vite</li>
            <li>🟢 Express.js</li>
            <li>🐳 Docker</li>
            <li>🏗️ Terraform</li>
            <li>☁️ AWS EC2</li>
          </ul>
        </div>
      </div>
    </div>
  )
}

export default App