import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import ShareModal from './ShareModal'

export default function Header({ onVideoShared }) {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [showModal, setShowModal] = useState(false)

  function handleLogout() {
    logout()
    navigate('/')
  }

  return (
    <>
      <header className="sticky top-0 z-40 bg-gray-900/80 backdrop-blur border-b border-white/10">
        <div className="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
          <Link to="/" className="text-xl font-bold text-white tracking-tight">
            🎬 <span className="text-indigo-400">YShare</span>
          </Link>

          <nav className="flex items-center gap-3">
            {user ? (
              <>
                <span className="text-sm text-gray-300">
                  Welcome, <span className="font-semibold text-white">{user.username}</span>
                </span>
                <button
                  id="share-video-btn"
                  onClick={() => setShowModal(true)}
                  className="px-4 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-medium transition-colors"
                >
                  Share Video
                </button>
                <button
                  id="logout-btn"
                  onClick={handleLogout}
                  className="px-4 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white text-sm font-medium transition-colors"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link
                  id="login-link"
                  to="/login"
                  className="px-4 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white text-sm font-medium transition-colors"
                >
                  Login
                </Link>
                <Link
                  id="register-link"
                  to="/register"
                  className="px-4 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-medium transition-colors"
                >
                  Register
                </Link>
              </>
            )}
          </nav>
        </div>
      </header>

      {showModal && (
        <ShareModal
          onClose={() => setShowModal(false)}
          onSuccess={(video) => {
            setShowModal(false)
            onVideoShared?.(video)
          }}
        />
      )}
    </>
  )
}
