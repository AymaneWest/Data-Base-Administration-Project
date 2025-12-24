import { PatronHeader } from "@/components/PatronHeader";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { MapPin, Phone, Mail, Clock, Users } from "lucide-react";
import { useEffect, useState } from "react";
import * as api from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";

interface Branch {
  branch_id: number;
  branch_name: string;
  address: string;
  phone?: string;
  email?: string;
  opening_hours?: string;
  branch_capacity?: number;
  library_id?: number;
}

export default function Branches() {
  const { user } = useAuth();
  const { toast } = useToast();
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadBranches();
  }, [user]);

  const loadBranches = async () => {
    setLoading(true);
    try {
      if (user) {
        // Try to get branches from the API
        // Note: This endpoint may need to be created in the backend
        try {
          const response = await api.getBranches();
          setBranches(response.data || []);
        } catch (error: any) {
          console.error("Failed to load branches:", error);
          // If endpoint doesn't exist, show a message
          if (error.response?.status === 404) {
            toast({
              title: "Info",
              description: "Branches endpoint not available. Please contact administrator.",
            });
          } else {
            toast({
              title: "Error",
              description: error.response?.data?.detail || "Failed to load branches",
              variant: "destructive",
            });
          }
        }
      }
    } catch (error: any) {
      console.error("Error loading branches:", error);
      toast({
        title: "Error",
        description: "An error occurred while loading branches",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <PatronHeader />
      
      <div className="border-b bg-muted/30">
        <div className="container mx-auto px-4 py-8">
          <h1 className="text-4xl font-bold mb-4">Library Branches</h1>
          <p className="text-muted-foreground">
            Find and visit any of our library branches across the city
          </p>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        {loading ? (
          <div className="text-center py-12">
            <p className="text-muted-foreground">Loading branches...</p>
          </div>
        ) : branches.length > 0 ? (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {branches.map((branch) => (
              <Card key={branch.branch_id} className="hover-elevate transition-all">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <CardTitle className="text-xl mb-2">{branch.branch_name}</CardTitle>
                      <CardDescription className="flex items-center gap-2 text-sm">
                        <MapPin className="h-4 w-4" />
                        {branch.address}
                      </CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {branch.phone && (
                    <div className="flex items-center gap-2 text-sm">
                      <Phone className="h-4 w-4 text-muted-foreground" />
                      <a href={`tel:${branch.phone}`} className="hover:text-primary">
                        {branch.phone}
                      </a>
                    </div>
                  )}
                  {branch.email && (
                    <div className="flex items-center gap-2 text-sm">
                      <Mail className="h-4 w-4 text-muted-foreground" />
                      <a href={`mailto:${branch.email}`} className="hover:text-primary">
                        {branch.email}
                      </a>
                    </div>
                  )}
                  {branch.opening_hours && (
                    <div className="flex items-center gap-2 text-sm">
                      <Clock className="h-4 w-4 text-muted-foreground" />
                      <span>{branch.opening_hours}</span>
                    </div>
                  )}
                  {branch.branch_capacity && (
                    <div className="flex items-center gap-2 text-sm">
                      <Users className="h-4 w-4 text-muted-foreground" />
                      <span>Capacity: {branch.branch_capacity} visitors</span>
                    </div>
                  )}
                </CardContent>
              </Card>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <MapPin className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
            <h3 className="text-xl font-semibold mb-2">No Branches Available</h3>
            <p className="text-muted-foreground">
              {user 
                ? "No branches found in the system. Please contact the administrator."
                : "Please log in to view library branches."}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

