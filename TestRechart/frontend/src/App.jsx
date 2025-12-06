import { useState, useEffect } from 'react'
import Chart from './Chart'
import './App.css'

const API_URL = 'http://localhost:5000'

function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function App() {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [chartType, setChartType] = useState('bar')
  const [dataSource, setDataSource] = useState('sql')
  const [period, setPeriod] = useState('daily')

  useEffect(() => {
    fetchData()
  }, [dataSource, period])

  const fetchData = async () => {
    setLoading(true)
    setError(null)
    
    try {
      const endpoint = dataSource === 'sql' ? '/api/chartdata' : '/api/sampledata'
      const url = `${API_URL}${endpoint}?period=${period}`
      const response = await fetch(url)
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result = await response.json()
      // Format dates for display
      const formattedData = result.map(item => ({
        ...item,
        date: item.date || item.name,
        formattedDate: formatDate(item.date || item.name)
      }))
      setData(formattedData)
    } catch (err) {
      setError(err.message)
      console.error('Error fetching data:', err)
    } finally {
      setLoading(false)
    }
  }

  const renderChart = () => {
    if (loading) {
      return <div className="message">Loading data...</div>
    }

    if (error) {
      return (
        <div className="message error">
          <p>Error loading data: {error}</p>
          <button onClick={fetchData} className="retry-button">Retry</button>
        </div>
      )
    }

    if (!data || data.length === 0) {
      return <div className="message">No data available</div>
    }

    return <Chart data={data} chartType={chartType} />
  }

  return (
    <div className="app">
      <div className="container">
        <header className="header">
          <h1>📊 TestRechart Demo</h1>
          <p>Visualizing SQL Database Data with Recharts</p>
        </header>

        <div className="controls">
          <div className="control-group">
            <label>Data Source:</label>
            <div className="button-group">
              <button 
                className={dataSource === 'sql' ? 'active' : ''}
                onClick={() => setDataSource('sql')}
              >
                SQL Database
              </button>
              <button 
                className={dataSource === 'sample' ? 'active' : ''}
                onClick={() => setDataSource('sample')}
              >
                Sample Data
              </button>
            </div>
          </div>

          <div className="control-group">
            <label>Period:</label>
            <div className="button-group">
              <button 
                className={period === 'daily' ? 'active' : ''}
                onClick={() => setPeriod('daily')}
              >
                Daily
              </button>
              <button 
                className={period === 'weekly' ? 'active' : ''}
                onClick={() => setPeriod('weekly')}
              >
                Weekly
              </button>
              <button 
                className={period === 'monthly' ? 'active' : ''}
                onClick={() => setPeriod('monthly')}
              >
                Monthly
              </button>
              <button 
                className={period === 'yearly' ? 'active' : ''}
                onClick={() => setPeriod('yearly')}
              >
                Yearly
              </button>
              <button 
                className={period === 'alltime' ? 'active' : ''}
                onClick={() => setPeriod('alltime')}
              >
                All Time
              </button>
            </div>
          </div>

          <div className="control-group">
            <label>Chart Type:</label>
            <div className="button-group">
              <button 
                className={chartType === 'bar' ? 'active' : ''}
                onClick={() => setChartType('bar')}
              >
                Bar Chart
              </button>
              <button 
                className={chartType === 'line' ? 'active' : ''}
                onClick={() => setChartType('line')}
              >
                Line Chart
              </button>
              <button 
                className={chartType === 'area' ? 'active' : ''}
                onClick={() => setChartType('area')}
              >
                Area Chart
              </button>
            </div>
          </div>

          <button onClick={fetchData} className="refresh-button" disabled={loading}>
            {loading ? '⏳ Loading...' : '🔄 Refresh Data'}
          </button>
        </div>

        <div className="chart-container">
          {renderChart()}
        </div>

        <div className="data-preview">
          <h3>Data Preview</h3>
          {data && data.length > 0 ? (
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Value</th>
                </tr>
              </thead>
              <tbody>
                {data.map((item, index) => (
                  <tr key={index}>
                    <td>{item.name}</td>
                    <td>${item.value.toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p>No data to display</p>
          )}
        </div>
      </div>
    </div>
  )
}

export default App
