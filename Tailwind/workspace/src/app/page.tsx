import ThemeButton from "@/components/ThemeButton";
import ColorShowcase from "@/components/ColorShowcase";
import ThemeChart from "@/components/ThemeChart";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 p-8">
      <main className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-primary-900 mb-4">
          Tailwind CSS Theme Demo
        </h1>
        <p className="text-lg text-primary-700 mb-8">
          This app demonstrates how to use custom theme colors in Tailwind CSS
        </p>

        {/* Button Examples */}
        <section className="mb-12">
          <h2 className="text-2xl font-semibold text-primary-800 mb-4">
            Button Examples with Theme Colors
          </h2>
          <div className="flex flex-wrap gap-4">
            <ThemeButton variant="primary" size="sm">
              Small Primary
            </ThemeButton>
            <ThemeButton variant="primary" size="md">
              Medium Primary
            </ThemeButton>
            <ThemeButton variant="primary" size="lg">
              Large Primary
            </ThemeButton>
          </div>

          <div className="flex flex-wrap gap-4 mt-4">
            <ThemeButton variant="secondary" size="md">
              Secondary Button
            </ThemeButton>
            <ThemeButton variant="accent" size="md">
              Accent Button
            </ThemeButton>
          </div>
        </section>

        {/* Color Showcase */}
        <section>
          <h2 className="text-2xl font-semibold text-primary-800 mb-4">
            Theme Color Palette
          </h2>
          <ColorShowcase />
        </section>
        {/* Charts Using Theme Colors */}
        <section className="mt-12">
          <h2 className="mb-4">Charts Using Theme Colors</h2>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            <ThemeChart variant="primary" title="Primary Theme Chart" />
            <ThemeChart variant="secondary" title="Secondary Theme Chart" />
          </div>
          <ThemeChart variant="all" title="All Theme Colors" />
        </section>

        {/* 
        {/* @layer Components Demo */}
        <section className="mt-12">
          <h2 className="mb-4">@layer Components Demo</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div className="card-primary">
              <h3>Primary Card</h3>
              <p className="text-primary-700 mt-2">
                This card uses the .card-primary class defined in @layer components
              </p>
              <span className="badge-primary mt-3">Primary Badge</span>
            </div>
            
            <div className="card-secondary">
              <h3>Secondary Card</h3>
              <p className="text-secondary-700 mt-2">
                This card uses the .card-secondary class defined in @layer components
              </p>
              <span className="badge-secondary mt-3">Secondary Badge</span>
            </div>
            
            <div className="card-accent">
              <h3>Accent Card</h3>
              <p className="text-accent-700 mt-2">
                This card uses the .card-accent class defined in @layer components
              </p>
              <span className="badge-accent mt-3">Accent Badge</span>
            </div>
          </div>

          <div className="card mb-6">
            <h3>@layer Utilities Demo</h3>
            <div className="space-y-4 mt-4">
              <div className="bg-gradient-primary text-white p-4 rounded-lg">
                Primary gradient background
              </div>
              <div className="bg-gradient-secondary text-white p-4 rounded-lg">
                Secondary gradient background
              </div>
              <div className="bg-gradient-accent text-white p-4 rounded-lg">
                Accent gradient background
              </div>
              <div className="p-4">
                <p className="text-gradient-primary text-4xl font-bold">
                  Primary text gradient
                </p>
                <p className="text-gradient-secondary text-4xl font-bold mt-2">
                  Secondary text gradient
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Code Examples */}
        <section className="mt-12 bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-2xl font-semibold text-primary-800 mb-4">
            How to Use @layer with Theme Colors
          </h2>
          <div className="space-y-4">
            <div>
              <h3 className="font-semibold text-primary-700 mb-2">@layer components in globals.css:</h3>
              <pre className="bg-gray-100 p-4 rounded overflow-x-auto">
                <code className="text-sm">
{`@layer components {
  .card-primary {
    @apply bg-primary-50 border-2 border-primary-200 
           rounded-lg p-6;
  }
  
  .badge-primary {
    @apply bg-primary-100 text-primary-800 
           px-3 py-1 rounded-full;
  }
}`}
                </code>
              </pre>
            </div>

            <div>
              <h3 className="font-semibold text-primary-700 mb-2">@layer utilities in globals.css:</h3>
              <pre className="bg-gray-100 p-4 rounded overflow-x-auto">
                <code className="text-sm">
{`@layer utilities {
  .bg-gradient-primary {
    @apply bg-gradient-to-r from-primary-400 
           to-primary-600;
  }
  
  .text-gradient-primary {
    @apply bg-gradient-to-r from-primary-500 
           to-primary-700 bg-clip-text 
           text-transparent;
  }
}`}
                </code>
              </pre>
            </div>

            <div>
              <h3 className="font-semibold text-primary-700 mb-2">Using in components:</h3>
              <pre className="bg-gray-100 p-4 rounded overflow-x-auto">
                <code className="text-sm">
{`<div className="card-primary">
  <h3>Title</h3>
  <span className="badge-primary">Badge</span>
</div>

<div className="bg-gradient-primary p-4">
  Gradient background
</div>`}
                </code>
              </pre>
            </div>

            <div>
              <h3 className="font-semibold text-primary-700 mb-2">Direct theme colors:</h3>
              <pre className="bg-gray-100 p-4 rounded overflow-x-auto">
                <code className="text-sm">
{`<button className="bg-primary-500 hover:bg-primary-600">
  Click me
</button>

<div className="bg-primary-100 text-primary-900">
  Light background, dark text
</div>`}
                </code>
              </pre>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
