import { useState } from 'react'
import './App.css'

const App = () => {

  const [count, setCount] = useState(0)

  return (
    <div className="container">
      <h1>Deployment Successfull!</h1>
      <p>This React app is deployed using:</p>
      <ul>
        <li>Docker</li>
        <li>Nginx</li>
        <li>Terraform</li>
        <li>Ansible</li>
        <li>GitHub Actions</li>
        <li>AWS EC2</li>

  
        <button onClick={() => setCount(count + 1)}>{`Count ${count}`}</button>
      </ul>
      <p className="success">This is a test. Deployment worked again!</p>
    </div>
  )
}

export default App