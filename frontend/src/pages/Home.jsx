import { useState, useEffect, useCallback, useImperativeHandle, forwardRef } from 'react'
import VideoCard from '../components/VideoCard'
import api from '../services/api'

const Home = forwardRef(function Home(_, ref) {
  const [videos, setVideos] = useState([])
  const [meta, setMeta] = useState(null)
  const [page, setPage] = useState(1)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useImperativeHandle(ref, () => ({
    prependVideo(video) {
      setVideos((prev) => [video, ...prev])
    },
  }))

  const fetchVideos = useCallback(async (p = 1) => {
    setLoading(true)
    setError('')
    try {
      const res = await api.get(`/videos?page=${p}`)
      setVideos(res.data.videos)
      setMeta(res.data.meta)
      setPage(p)
    } catch {
      setError('Failed to load videos.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchVideos(1)
  }, [fetchVideos])

  return (
    <main className="max-w-5xl mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-white">Shared Videos</h1>
        {meta && (
          <span className="text-sm text-gray-400">{meta.total_count} videos</span>
        )}
      </div>

      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-8 h-8 rounded-full border-2 border-indigo-500 border-t-transparent animate-spin" />
        </div>
      )}

      {error && (
        <p className="text-center text-red-400 py-10">{error}</p>
      )}

      {!loading && !error && videos.length === 0 && (
        <div className="text-center py-20">
          <p className="text-4xl mb-3">🎬</p>
          <p className="text-gray-400">No videos shared yet. Be the first!</p>
        </div>
      )}

      <div className="flex flex-col gap-4">
        {videos.map((video) => (
          <VideoCard key={video.id} video={video} />
        ))}
      </div>

      {meta && meta.total_pages > 1 && (
        <div className="flex justify-center gap-2 mt-8">
          <button
            disabled={page <= 1}
            onClick={() => fetchVideos(page - 1)}
            className="px-4 py-2 rounded-lg bg-white/10 hover:bg-white/20 disabled:opacity-30 text-white text-sm transition-colors"
          >
            ← Prev
          </button>
          <span className="px-4 py-2 text-gray-400 text-sm">
            {page} / {meta.total_pages}
          </span>
          <button
            disabled={page >= meta.total_pages}
            onClick={() => fetchVideos(page + 1)}
            className="px-4 py-2 rounded-lg bg-white/10 hover:bg-white/20 disabled:opacity-30 text-white text-sm transition-colors"
          >
            Next →
          </button>
        </div>
      )}
    </main>
  )
})

export default Home
