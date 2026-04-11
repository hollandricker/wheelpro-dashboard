import { useEffect } from 'react'

export default function App() {
  useEffect(() => {
    window.location.href = '/dashboard.html'
  }, [])

  return null
}
