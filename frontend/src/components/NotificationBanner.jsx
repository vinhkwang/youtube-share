import { useEffect, useState } from 'react'

export default function NotificationBanner({ notifications, onDismiss }) {
  return (
    <div className="fixed top-20 right-4 z-50 flex flex-col gap-2 max-w-sm w-full">
      {notifications.map((n) => (
        <Notification key={n.id} notification={n} onDismiss={onDismiss} />
      ))}
    </div>
  )
}

function Notification({ notification, onDismiss }) {
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    requestAnimationFrame(() => setVisible(true))
    const timer = setTimeout(() => {
      setVisible(false)
      setTimeout(() => onDismiss(notification.id), 300)
    }, 5000)
    return () => clearTimeout(timer)
  }, [])

  return (
    <div
      className={`flex items-start gap-3 bg-gray-800 border border-indigo-500/40 rounded-xl shadow-xl p-4 transition-all duration-300 ${
        visible ? 'opacity-100 translate-x-0' : 'opacity-0 translate-x-8'
      }`}
    >
      <span className="text-xl shrink-0">🎬</span>
      <div className="min-w-0">
        <p className="text-sm text-white leading-snug">
          <span className="font-semibold text-indigo-400">{notification.shared_by}</span>
          {' shared: '}
          <span className="text-gray-200">{notification.video?.title}</span>
        </p>
      </div>
      <button
        onClick={() => onDismiss(notification.id)}
        className="ml-auto shrink-0 text-gray-500 hover:text-white transition-colors text-lg leading-none"
      >
        ×
      </button>
    </div>
  )
}
