# Library Management System - Design Guidelines

## Design Approach

**Dual-Application Strategy:** Two distinct visual identities serving different user needs.

**Patron Portal:** Reference-based approach inspired by Netflix (discovery), Goodreads (book browsing), and Airbnb (clean search interfaces). Emphasizes visual appeal, book covers, and engaging browsing experience.

**Staff Dashboard:** Design system approach using Stripe Dashboard principles (clean metrics), Linear (modern data interfaces), and Shopify Admin (operational efficiency). Prioritizes information density and workflow optimization.

---

## Typography System

**Patron Portal:**
- Headlines: Inter or Poppins (600-700 weight) for friendly, modern feel
- Body: Inter (400-500 weight) for readability
- Book titles: 500-600 weight for emphasis
- Metadata: 400 weight, smaller sizes for authors/publishers

**Staff Dashboard:**
- Headlines: Inter (600 weight) for consistency
- Body: Inter (400-500 weight) optimized for scanning
- Data tables: Tabular figures, 400 weight
- Labels: 500 weight, uppercase for form fields

---

## Layout System

**Spacing:** Tailwind units of 2, 4, 6, 8, 12, 16, 20, 24 for consistent rhythm

**Patron Portal Grid:**
- Hero: Full-width with max-w-7xl container
- Book catalog: 2-column mobile, 3-4 column tablet/desktop grid
- Content sections: max-w-6xl for reading comfort
- Book details: 2-column split (image left, details right)

**Staff Dashboard Grid:**
- Sidebar navigation: 240px fixed width
- Main content: Fluid with max-w-screen-2xl
- Dashboard cards: 2-3 column grid for metrics
- Data tables: Full-width with horizontal scroll
- Forms: max-w-2xl centered for focus

---

## Component Library

### Patron Portal Components

**Navigation:**
- Fixed header with library logo, search bar, and account menu
- Transparent on hero, solid white on scroll with subtle shadow
- Mobile: Hamburger menu with slide-out drawer

**Hero Section:**
- Large hero image (library interior or books) with gradient overlay
- Prominent search bar (centered, white background, rounded-xl)
- Featured new releases carousel below hero

**Book Cards:**
- Vertical layout with cover image (2:3 ratio)
- Title (truncated after 2 lines), author below
- Availability badge (green="Available", yellow="Reserved", gray="Checked Out")
- Hover: Subtle lift with shadow increase

**Search & Filters:**
- Sticky filter sidebar on desktop (genres, type, availability, year range)
- Filter chips showing active selections
- Sort dropdown (relevance, title, author, newest)

**Book Details Modal/Page:**
- Large cover image (left)
- Title, author, ISBN, publisher (right)
- Tabs: Description, Reviews, Availability by Branch
- Branch availability table with "Reserve" buttons
- Related books carousel

**Account Dashboard:**
- Stats cards (current loans, fines owed, reservations)
- Loan table with progress bars for due dates
- Fine payment interface with total due and itemized list

### Staff Dashboard Components

**Sidebar Navigation:**
- Logo at top
- Grouped menu items (Dashboard, Circulation, Patrons, Catalog, Reports, Admin)
- Active state: Background fill, bold text
- Collapsed state on mobile

**Dashboard Cards:**
- Metric cards: Large number, label, trend indicator (↑↓)
- Alert cards: Color-coded borders (red=overdue, yellow=low stock)
- Quick action buttons: Icon + label in grid layout

**Data Tables:**
- Sticky header row
- Alternating row backgrounds for scannability
- Action column (right) with icon buttons
- Pagination footer
- Search and column filters

**Forms:**
- Clear labels above inputs
- Helper text below fields
- Error states with red border and message
- Multi-step wizards for complex operations (e.g., new material entry)

**Barcode Scanner Interface:**
- Large input field mimicking scanner
- Recent scans list below
- Visual feedback on successful scan (green flash)

**Charts & Analytics:**
- Line charts for trends (circulation over time)
- Bar charts for comparisons (popular genres)
- Donut charts for categorical data (material types)
- Date range picker for filtering

**API Health Monitor:**
- Status cards with green/red indicators
- Response time line graph
- Error log table with severity badges
- Real-time updates (polling every 30s)

---

## Interactions & Animations

**Patron Portal:**
- Smooth page transitions (fade in content)
- Book card hover: Scale 1.02, shadow increase
- Search: Debounced input with loading spinner
- Infinite scroll for catalog (load more as user scrolls)
- Modal transitions: Fade in overlay, slide up content

**Staff Dashboard:**
- Minimal animations for speed
- Table row hover: Background change only
- Form submit: Button loading state
- Toast notifications: Slide in from top-right
- Sidebar toggle: Smooth width transition

---

## Images

### Patron Portal Images
- **Hero Section:** Full-width library interior or stacked books (1920x800px minimum), gradient overlay for text readability
- **Book Covers:** 300x450px minimum, placeholder for missing covers
- **Branch Photos:** 600x400px for branch pages
- **Category Headers:** Wide banners (1200x300px) for genre landing pages

### Staff Dashboard Images
- **Profile Photos:** User avatars (150x150px) for patron records
- **Material Covers:** Thumbnails (100x150px) in tables and forms
- Minimal decorative imagery - focus on data visualization

---

## Responsive Breakpoints

- Mobile: < 768px (single column, stacked layouts)
- Tablet: 768px - 1024px (2-column grids, collapsible sidebar)
- Desktop: > 1024px (full multi-column layouts)

**Key Responsive Patterns:**
- Patron catalog: 1 col → 2 col → 4 col
- Staff sidebar: Collapsed icon-only → Full width
- Data tables: Horizontal scroll on mobile, full on desktop
- Dashboard metrics: Stacked → 2x2 grid → 4 columns

---

## Accessibility Standards

- Keyboard navigation for all interactive elements
- Focus indicators (2px outline offset)
- ARIA labels for icon-only buttons
- Color contrast minimum 4.5:1 for text
- Form validation with clear error messages
- Screen reader-friendly table markup
- Skip to main content link