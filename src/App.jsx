import { useState } from 'react'
import './App.css'

const App = () => {

  const [count, setCount] = useState(0)


  return (
    <div className="container">
      <h1>🚀 Hello World from DevOps!</h1>
      <p>This React app is deployed using:</p>
      <ul>
        <li>✅ Docker</li>
        <li>✅ Nginx</li>
        <li>✅ Terraform</li>
        <li>✅ Ansible</li>
        <li>✅ GitHub Actions</li>
        <li>✅ AWS EC2</li>
        <li>Just now EC2 was Provisioned. Test Change</li>
        <button onClick={() => setCount(count + 1)}>{`Count ${count}`}</button>
      </ul>
      <p className="success">🎉 Deployment Successful!</p>
    </div>
  )
}

export default App