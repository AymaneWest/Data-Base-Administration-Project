import { useEffect, useState } from "react";
import { useParams, useLocation } from "wouter";
import { PatronHeader } from "@/components/PatronHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { useToast } from "@/hooks/use-toast";
import * as api from "@/lib/api";
import { useAuth } from "@/lib/auth";
import {
  BookOpen,
  MapPin,
  Calendar,
  Users,
  Clock,
  AlertCircle,
  CheckCircle,
  TrendingUp,
  Library
} from "lucide-react";

export default function BookDetails() {
  const { materialId } = useParams();
  const { user } = useAuth();
  const [, setLocation] = useLocation();
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [details, setDetails] = useState<any>(null);
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    console.log("User from auth:", user);
    console.log("Patron ID:", user?.patron_id);
    loadBookDetails();
  }, [materialId]);

  const loadBookDetails = async () => {
    if (!materialId) return;
    setLoading(true);
    try {
      const response = await api.getMaterialDetails(materialId);
      setDetails(response.data);
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.response?.data?.detail || "Failed to load book details",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const [selectedBranch, setSelectedBranch] = useState<number | null>(null);

  const handleCheckout = async () => {
  if (!user?.id) {
    toast({
      title: "Authentication Required",
      description: "Please log in to borrow books",
      variant: "destructive",
    });
    setLocation("/login");
    return;
  }

  if (!selectedBranch) {
    toast({
      title: "Select a Branch",
      description: "Please choose which branch to pick up from",
      variant: "destructive",
    });
    return;
  }

  const branch = details.branch_availability.find((b: any) => b.branch_id === selectedBranch);
  const copyId = branch?.copy_ids[0];

  if (!copyId) {
    toast({
      title: "No Copies Available",
      description: "This branch has no available copies",
      variant: "destructive",
    });
    return;
  }

  setActionLoading(true);
  try {
    const response = await api.checkoutMaterial({
      copy_id: copyId,
      patron_id: user.id,  // Use user.id instead of user.patron_id
    });
    
    if (response?.data?.success) {
      toast({
        title: "Success!",
        description: `Book checked out. Due date: ${response.data.due_date}`,
      });
      loadBookDetails();
    } else {
      toast({
        title: "Checkout Failed",
        description: response?.data?.message || "Unknown error occurred",
        variant: "destructive",
      });
    }
  } catch (error: any) {
    console.error("Checkout error:", error);
    toast({
      title: "Error",
      description: error?.response?.data?.detail || error?.message || "Failed to checkout",
      variant: "destructive",
    });
  } finally {
    setActionLoading(false);
  }
};

const handleReserve = async () => {
  if (!user?.id) {
    toast({
      title: "Authentication Required",
      description: "Please log in to reserve books",
      variant: "destructive",
    });
    setLocation("/login");
    return;
  }

  setActionLoading(true);
  try {
    const response = await api.placeReservation({
      material_id: parseInt(materialId!),
      patron_id: user.id,
    });
    
    console.log("Full response:", response); // Add this
    console.log("Response data:", response.data); // Add this
    
    if (response?.data?.success) {
      toast({
        title: "Reserved!",
        description: response.data.message || "You'll be notified when the book is available",
      });
      loadBookDetails();
    } else {
      toast({
        title: "Reservation Failed",
        description: response?.data?.message || "Unknown error occurred",
        variant: "destructive",
      });
    }
  } catch (error: any) {
    console.error("Reserve error:", error);
    console.error("Error details:", error?.response?.data);
    
    let errorMessage = "Failed to reserve";
    if (error?.response?.data?.detail) {
      const detail = error.response.data.detail;
      if (Array.isArray(detail)) {
        errorMessage = detail.map((e: any) => e.msg).join(", ");
      } else if (typeof detail === "string") {
        errorMessage = detail;
      }
    }
    
    toast({
      title: "Error",
      description: errorMessage,
      variant: "destructive",
    });
  } finally {
    setActionLoading(false);
  }
};

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <PatronHeader />
        <div className="container mx-auto px-4 py-8">
          <p className="text-center text-muted-foreground">Loading book details...</p>
        </div>
      </div>
    );
  }

  if (!details) {
    return (
      <div className="min-h-screen bg-background">
        <PatronHeader />
        <div className="container mx-auto px-4 py-8">
          <p className="text-center text-muted-foreground">Book not found</p>
        </div>
      </div>
    );
  }

  const primaryGenre = details.genres.find((g: any) => g.is_primary);
  const totalAvailable = details.branch_availability.reduce(
    (sum: number, b: any) => sum + b.available_copies, 0
  );

  return (
    <div className="min-h-screen bg-background">
      <PatronHeader />
      
      <div className="container mx-auto px-4 py-8">
        <Button 
          variant="ghost" 
          onClick={() => setLocation("/catalog")}
          className="mb-4"
        >
          ← Back to Catalog
        </Button>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Header */}
            <div>
              <div className="flex gap-2 mb-2">
                {primaryGenre && (
                  <Badge variant="secondary">{primaryGenre.name}</Badge>
                )}
                <Badge variant="outline">{details.material_type}</Badge>
                {details.is_new_release && (
                  <Badge className="bg-green-600">New Release</Badge>
                )}
              </div>
              
              <h1 className="text-4xl font-bold mb-2">{details.title}</h1>
              {details.subtitle && (
                <p className="text-xl text-muted-foreground mb-4">{details.subtitle}</p>
              )}
              
              <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
                {details.authors.map((author: any, idx: number) => (
                  <span key={author.author_id}>
                    {idx > 0 && ", "}
                    {author.name}
                  </span>
                ))}
              </div>
            </div>

            <Separator />

            {/* Action Buttons */}
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      {totalAvailable > 0 ? (
                        <>
                          <CheckCircle className="h-5 w-5 text-green-600" />
                          <span className="font-semibold text-green-600">
                            {totalAvailable} Available
                          </span>
                        </>
                      ) : (
                        <>
                          <AlertCircle className="h-5 w-5 text-red-600" />
                          <span className="font-semibold text-red-600">
                            All Checked Out
                          </span>
                        </>
                      )}
                    </div>
                    
                    {details.patron_already_has_it && (
                      <p className="text-sm text-muted-foreground">
                        You currently have this book
                      </p>
                    )}
                    {details.patron_already_reserved && (
                      <p className="text-sm text-muted-foreground">
                        You already reserved this book
                      </p>
                    )}
                    {details.current_reservations_count > 0 && !details.patron_already_reserved && (
                      <p className="text-sm text-muted-foreground">
                        {details.current_reservations_count} people in queue
                        {details.estimated_wait_days && ` • ~${details.estimated_wait_days} days wait`}
                      </p>
                    )}
                  </div>

                  <div className="flex gap-2">                    
                    <div className="flex gap-2">
                    {details.patron_can_borrow && (
                        <Button 
                        onClick={handleCheckout}
                        disabled={actionLoading}
                        size="lg"
                        >
                        <BookOpen className="h-4 w-4 mr-2" />
                        Borrow Now
                        </Button>
                    )}
                    
                    {totalAvailable === 0 && !details.patron_already_reserved && !details.patron_already_has_it && (
                        <Button 
                        onClick={handleReserve}
                        disabled={actionLoading}
                        variant="outline"
                        size="lg"
                        >
                        <Clock className="h-4 w-4 mr-2" />
                        Reserve
                        </Button>
                    )}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Description */}
            {details.description && (
              <Card>
                <CardHeader>
                  <CardTitle>Description</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-muted-foreground leading-relaxed">
                    {details.description}
                  </p>
                </CardContent>
              </Card>
            )}

            {/* Publication Details */}
            <Card>
              <CardHeader>
                <CardTitle>Publication Details</CardTitle>
              </CardHeader>
              <CardContent className="grid grid-cols-2 gap-4">
                {details.publisher_name && (
                  <div>
                    <p className="text-sm text-muted-foreground">Publisher</p>
                    <p className="font-medium">{details.publisher_name}</p>
                  </div>
                )}
                {details.publication_year && (
                  <div>
                    <p className="text-sm text-muted-foreground">Year</p>
                    <p className="font-medium">{details.publication_year}</p>
                  </div>
                )}
                {details.isbn && (
                  <div>
                    <p className="text-sm text-muted-foreground">ISBN</p>
                    <p className="font-medium">{details.isbn}</p>
                  </div>
                )}
                {details.language && (
                  <div>
                    <p className="text-sm text-muted-foreground">Language</p>
                    <p className="font-medium">{details.language}</p>
                  </div>
                )}
                {details.pages && (
                  <div>
                    <p className="text-sm text-muted-foreground">Pages</p>
                    <p className="font-medium">{details.pages}</p>
                  </div>
                )}
                {details.edition && (
                  <div>
                    <p className="text-sm text-muted-foreground">Edition</p>
                    <p className="font-medium">{details.edition}</p>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Branch Availability */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <MapPin className="h-5 w-5" />
                  Choose Pickup Branch
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {details.branch_availability.map((branch: any) => (
                  <div 
                    key={branch.branch_id}
                    onClick={() => branch.available_copies > 0 && setSelectedBranch(branch.branch_id)}
                    className={`p-4 border rounded-lg cursor-pointer transition-all ${
                      selectedBranch === branch.branch_id 
                        ? 'border-primary bg-primary/5 ring-2 ring-primary' 
                        : branch.available_copies > 0 
                          ? 'hover:border-primary hover:bg-accent' 
                          : 'opacity-50 cursor-not-allowed'
                    }`}
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <h4 className="font-semibold">{branch.branch_name}</h4>
                        <p className="text-sm text-muted-foreground">{branch.address}</p>
                        <p className="text-sm text-muted-foreground">{branch.phone}</p>
                      </div>
                      <Badge variant={branch.available_copies > 0 ? "default" : "secondary"}>
                        {branch.available_copies} of {branch.total_copies} available
                      </Badge>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Stats */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TrendingUp className="h-5 w-5" />
                  Popularity
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <p className="text-sm text-muted-foreground">Borrowed (Last 30 Days)</p>
                  <p className="text-2xl font-bold">{details.times_borrowed_last_30_days}</p>
                </div>
                <Separator />
                <div>
                  <p className="text-sm text-muted-foreground">Total Borrows</p>
                  <p className="text-2xl font-bold">{details.times_borrowed_all_time}</p>
                </div>
              </CardContent>
            </Card>

            {/* Genres */}
            {details.genres.length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle>Genres</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex flex-wrap gap-2">
                    {details.genres.map((genre: any) => (
                      <Badge 
                        key={genre.genre_id}
                        variant={genre.is_primary ? "default" : "secondary"}
                      >
                        {genre.name}
                      </Badge>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Similar Books */}
            {details.similar_books.length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle>You Might Also Like</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {details.similar_books.map((book: any) => (
                    <div 
                      key={book.material_id}
                      className="p-3 border rounded-lg hover:bg-accent cursor-pointer transition-colors"
                      onClick={() => setLocation(`/catalog/${book.material_id}`)}
                    >
                      <h4 className="font-semibold text-sm line-clamp-2">{book.title}</h4>
                      <p className="text-xs text-muted-foreground mt-1">{book.author}</p>
                      <Badge variant="outline" className="mt-2 text-xs">
                        {book.available_copies} available
                      </Badge>
                    </div>
                  ))}
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}