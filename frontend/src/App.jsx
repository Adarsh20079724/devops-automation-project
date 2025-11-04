import React, { useEffect, useState } from 'react'

const App = () => {
  const [message, setMessage] = useState('Loading...')
  const [count, setCount] = useState(0)

  const fetchData = async () => {
    try{
    const response = await fetch('http://localhost:3000/api/hello');
    const data = await response.json();

    setMessage(data)
    }
    catch(err) {
      console.error('Error:', err)
        setMessage('Error connecting to backend')
    }
  }

  useEffect(() => {
    // Fetch message from backend
    fetchData();
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