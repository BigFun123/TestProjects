import { useQuery } from '@tanstack/react-query'
import './index.css'

// API function to fetch posts
const fetchPosts = async () => {
  const response = await fetch('https://jsonplaceholder.typicode.com/posts')
  if (!response.ok) {
    throw new Error('Network response was not ok')
  }
  return response.json()
}

function App() {
  // Using TanStack Query to fetch posts
  const { data: posts, isLoading, isError, error, refetch, isFetching } = useQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return (
    <div className="app">
      <h1>🚀 TanStack Query Demo</h1>
      <p className="subtitle">
        Fetching posts from JSONPlaceholder API with smart caching and automatic refetching
      </p>

      <div className="controls">
        <button onClick={() => refetch()} disabled={isFetching}>
          {isFetching ? '🔄 Refetching...' : '🔄 Refetch Data'}
        </button>
      </div>

      {/* Status indicator */}
      {isLoading && (
        <div className="status loading">
          ⏳ Loading posts for the first time...
        </div>
      )}

      {isFetching && !isLoading && (
        <div className="status loading">
          🔄 Updating posts...
        </div>
      )}

      {!isLoading && !isError && !isFetching && (
        <div className="status success">
          ✅ Data loaded successfully! Showing {posts?.length} posts
        </div>
      )}

      {/* Error state */}
      {isError && (
        <div className="error-message">
          <h2>❌ Error Loading Posts</h2>
          <p>{error.message}</p>
          <button onClick={() => refetch()}>Try Again</button>
        </div>
      )}

      {/* Loading spinner */}
      {isLoading && (
        <div className="loading-spinner">
          <div className="spinner"></div>
        </div>
      )}

      {/* Posts grid */}
      {!isLoading && posts && (
        <div className="posts-grid">
          {posts.slice(0, 12).map((post) => (
            <div key={post.id} className="post-card">
              <span className="post-id">Post #{post.id}</span>
              <h3 className="post-title">{post.title}</h3>
              <p className="post-body">{post.body}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default App
