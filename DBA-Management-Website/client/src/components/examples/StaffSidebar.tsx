import { StaffSidebar } from '../StaffSidebar';

export default function StaffSidebarExample() {
  return (
    <div className="flex h-screen">
      <StaffSidebar />
      <div className="flex-1 p-8">
        <h1 className="text-2xl font-bold mb-4">Main Content Area</h1>
        <p className="text-muted-foreground">Sidebar navigation appears on the left</p>
      </div>
    </div>
  );
}