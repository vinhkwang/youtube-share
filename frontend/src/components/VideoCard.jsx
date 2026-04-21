import { formatDistanceToNow } from '../utils/time'

export default function VideoCard({ video }) {
  return (
    <div className="flex gap-4 bg-white/5 hover:bg-white/8 border border-white/10 rounded-xl p-4 transition-colors">
      <a
        href={video.youtube_url}
        target="_blank"
        rel="noopener noreferrer"
        className="shrink-0"
      >
        <img
          src={video.thumbnail_url}
          alt={video.title}
          className="w-40 h-24 object-cover rounded-lg bg-gray-800"
        />
      </a>

      <div className="flex flex-col justify-between min-w-0">
        <div>
          <a
            href={video.youtube_url}
            target="_blank"
            rel="noopener noreferrer"
            className="block font-semibold text-white hover:text-indigo-400 transition-colors line-clamp-2 leading-snug"
          >
            {video.title}
          </a>
          {video.description && (
            <p className="mt-1 text-sm text-gray-400 line-clamp-2">{video.description}</p>
          )}
        </div>

        <div className="flex items-center gap-3 text-xs text-gray-500 mt-2">
          <span>
            Shared by <span className="text-indigo-400 font-medium">{video.shared_by}</span>
          </span>
          <span>·</span>
          <span>{formatDistanceToNow(video.shared_at)}</span>
        </div>
      </div>
    </div>
  )
}
