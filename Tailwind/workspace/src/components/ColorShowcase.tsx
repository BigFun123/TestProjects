import React from 'react';

const ColorShowcase: React.FC = () => {
  const colorThemes = [
    {
      name: 'Primary',
      shades: [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950],
      colorClass: 'primary',
    },
    {
      name: 'Secondary',
      shades: [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950],
      colorClass: 'secondary',
    },
    {
      name: 'Accent',
      shades: [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950],
      colorClass: 'accent',
    },
  ];

  return (
    <div className="space-y-6">
      {colorThemes.map((theme) => (
        <div key={theme.name} className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-xl font-semibold mb-4 text-gray-800">{theme.name} Theme</h3>
          <div className="grid grid-cols-11 gap-2">
            {theme.shades.map((shade) => (
              <div key={shade} className="flex flex-col items-center">
                <div
                  className={`w-full h-16 rounded-md shadow-sm bg-${theme.colorClass}-${shade}`}
                  title={`${theme.colorClass}-${shade}`}
                />
                <span className="text-xs mt-1 text-gray-600">{shade}</span>
              </div>
            ))}
          </div>
          <div className="mt-3 text-sm text-gray-600">
            Usage: <code className="bg-gray-100 px-2 py-1 rounded">bg-{theme.colorClass}-500</code>
          </div>
        </div>
      ))}
    </div>
  );
};

export default ColorShowcase;
