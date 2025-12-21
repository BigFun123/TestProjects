# Tailwind CSS Theme Demo

A Next.js application demonstrating how to use custom themes in Tailwind CSS.

## Features

- **Custom Theme Colors**: Three custom color palettes (Primary, Secondary, Accent) with full shade ranges
- **Reusable Components**: Theme-aware button component with variants and sizes
- **Color Showcase**: Visual display of all theme colors with usage examples
- **TypeScript**: Full TypeScript support for type safety
- **Responsive Design**: Mobile-friendly layout with Tailwind utilities

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm, yarn, pnpm, or bun

### Installation

The dependencies are already installed. If you need to reinstall:

```bash
npm install
```

### Running the Development Server

Start the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Building for Production

```bash
npm run build
npm start
```

## Project Structure

```
src/
├── app/
│   ├── globals.css      # Global styles with Tailwind directives
│   ├── layout.tsx       # Root layout component
│   └── page.tsx         # Home page showcasing themes
└── components/
    ├── ThemeButton.tsx      # Button component using theme colors
    └── ColorShowcase.tsx    # Color palette display component
```

## Theme Configuration

Custom theme colors are defined in [tailwind.config.ts](tailwind.config.ts):

```typescript
theme: {
  extend: {
    colors: {
      primary: { /* Blue shades */ },
      secondary: { /* Purple shades */ },
      accent: { /* Orange shades */ },
    },
  },
}
```

## Using Theme Colors

### In Components

```tsx
// Button with primary theme
<button className="bg-primary-500 hover:bg-primary-600">
  Click me
</button>

// Text with secondary theme
<h1 className="text-secondary-700">
  Heading
</h1>

// Background with accent theme
<div className="bg-accent-100 border-accent-500">
  Content
</div>
```

### Available Shades

Each theme color includes shades: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950

## Components

### ThemeButton

A reusable button component with theme support:

```tsx
<ThemeButton variant="primary" size="md">
  Button Text
</ThemeButton>
```

**Props:**
- `variant`: 'primary' | 'secondary' | 'accent'
- `size`: 'sm' | 'md' | 'lg'
- `onClick`: Optional click handler

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Tailwind Theme Configuration](https://tailwindcss.com/docs/theme)

## License

MIT
