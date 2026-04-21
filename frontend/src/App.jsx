import { useState, useCallback, useRef } from 'react'
import { Routes, Route } from 'react-router-dom'
import Header from './components/Header'
import NotificationBanner from './components/NotificationBanner'
import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import { useActionCable } from './hooks/useActionCable'

export default function App() {
  const [notifications, setNotifications] = useState([])
  const homeRef = useRef(null)

  const addNotification = useCallback((data) => {
    if (data.type !== 'new_video') return
    setNotifications((prev) => [...prev, { ...data, id: Date.now() }])
  }, [])

  function dismissNotification(id) {
    setNotifications((prev) => prev.filter((n) => n.id !== id))
  }

  function handleVideoShared(video) {
    homeRef.current?.prependVideo(video)
  }

  useActionCable(addNotification)

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      <Header onVideoShared={handleVideoShared} />
      <NotificationBanner
        notifications={notifications}
        onDismiss={dismissNotification}
      />
      <Routes>
        <Route path="/" element={<Home ref={homeRef} />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
      </Routes>
    </div>
  )
}
