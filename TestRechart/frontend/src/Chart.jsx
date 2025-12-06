import { BarChart, Bar, LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

function Chart({ data, chartType }) {
  const chartProps = {
    data,
    margin: { top: 20, right: 30, left: 20, bottom: 20 }
  }

  switch (chartType) {
    case 'line':
      return (
        <ResponsiveContainer width="100%" height={400}>
          <LineChart {...chartProps}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
            <XAxis dataKey="formattedDate" stroke="#333" angle={-45} textAnchor="end" height={80} />
            <YAxis stroke="#333" />
            <Tooltip 
              contentStyle={{ backgroundColor: '#fff', border: '1px solid #ddd' }}
              formatter={(value) => [`$${value.toLocaleString()}`, 'Value']}
            />
            <Legend />
            <Line type="monotone" dataKey="value" stroke="#8884d8" strokeWidth={2} dot={{ r: 5 }} />
          </LineChart>
        </ResponsiveContainer>
      )
    
    case 'area':
      return (
        <ResponsiveContainer width="100%" height={400}>
          <AreaChart {...chartProps}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
            <XAxis dataKey="formattedDate" stroke="#333" angle={-45} textAnchor="end" height={80} />
            <YAxis stroke="#333" />
            <Tooltip 
              contentStyle={{ backgroundColor: '#fff', border: '1px solid #ddd' }}
              formatter={(value) => [`$${value.toLocaleString()}`, 'Value']}
            />
            <Legend />
            <Area type="monotone" dataKey="value" stroke="#82ca9d" fill="#82ca9d" fillOpacity={0.6} />
          </AreaChart>
        </ResponsiveContainer>
      )
    
    default:
      return (
        <ResponsiveContainer width="100%" height={400}>
          <BarChart {...chartProps}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
            <XAxis dataKey="formattedDate" stroke="#333" angle={-45} textAnchor="end" height={80} />
            <YAxis stroke="#333" />
            <Tooltip 
              contentStyle={{ backgroundColor: '#fff', border: '1px solid #ddd' }}
              formatter={(value) => [`$${value.toLocaleString()}`, 'Value']}
            />
            <Legend />
            <Bar dataKey="value" fill="#8884d8" />
          </BarChart>
        </ResponsiveContainer>
      )
  }
}

export default Chart
