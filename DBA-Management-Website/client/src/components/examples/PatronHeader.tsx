import { PatronHeader } from '../PatronHeader';
import { AuthProvider } from '@/lib/auth';

export default function PatronHeaderExample() {
  return (
    <AuthProvider>
      <div className="min-h-screen">
        <PatronHeader />
        <div className="container mx-auto p-8">
          <p className="text-muted-foreground">Header content appears above</p>
        </div>
      </div>
    </AuthProvider>
  );
}