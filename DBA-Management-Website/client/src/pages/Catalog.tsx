import { PatronHeader } from "@/components/PatronHeader";
import { SearchBar } from "@/components/SearchBar";
import { BookCard } from "@/components/BookCard";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Grid3x3, List, SlidersHorizontal } from "lucide-react";
import { useState, useEffect } from "react";
import * as api from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { useLocation } from "wouter";

interface Material {
  material_id: number;
  title: string;
  authors?: string;
  genres?: string;
  material_type?: string;
  availability_status?: "available" | "reserved" | "checked-out" | "unavailable";
  available_copies?: number;
  isbn?: string;
}

interface Genre {
  genre_id: number;
  genre_name: string;
}

export default function Catalog() {
  const { user } = useAuth();
  const { toast } = useToast();
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid");
  const [showFilters, setShowFilters] = useState(true);
  const [materials, setMaterials] = useState<Material[]>([]);
  const [genres, setGenres] = useState<Genre[]>([]);
  const [loading, setLoading] = useState(true);
  const [, setLocation] = useLocation();
  
  // Search and filter states
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedGenres, setSelectedGenres] = useState<string[]>([]);
  const [selectedMaterialTypes, setSelectedMaterialTypes] = useState<string[]>(["Book"]);
  const [selectedAvailability, setSelectedAvailability] = useState<string[]>([]);
  const [sortBy, setSortBy] = useState<string>("relevance");

  useEffect(() => {
    if (user) {
      loadGenres();
      loadMaterials();
    } else {
      setMaterials([]);
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    if (user) {
      loadMaterials();
    }
  }, [searchQuery, selectedGenres, selectedMaterialTypes, selectedAvailability, sortBy, user]);

  const loadGenres = async () => {
    try {
      const response = await api.getGenres();
      setGenres(response.data || []);
    } catch (error) {
      console.error("Failed to load genres:", error);
    }
  };

  const loadMaterials = async () => {
    setLoading(true);
    try {
      const filters: any = {
        sort_by: sortBy,
      };

      if (searchQuery) {
        filters.search = searchQuery;
      }

      if (selectedGenres.length > 0) {
        filters.genre = selectedGenres[0];
      }

      if (selectedMaterialTypes.length > 0) {
        filters.material_type = selectedMaterialTypes[0];
      }

      if (selectedAvailability.length > 0) {
        filters.availability = selectedAvailability[0];
      }

      const response = await api.browseMaterials(filters);
      
      let results: Material[] = [];
      if (response?.data) {
        if (Array.isArray(response.data)) {
          results = response.data;
        } else {
          console.error("Unexpected API response format:", response.data);
          results = [];
        }
      }

      if (selectedGenres.length > 1 || selectedMaterialTypes.length > 1 || selectedAvailability.length > 1) {
        results = results.filter((material: Material) => {
          if (selectedGenres.length > 0) {
            const materialGenres = (material.genres || "").split(", ");
            if (!selectedGenres.some(genre => materialGenres.includes(genre))) {
              return false;
            }
          }

          if (selectedMaterialTypes.length > 0 && material.material_type) {
            const typeMatch = selectedMaterialTypes.some(type => 
              material.material_type?.toLowerCase().includes(type.toLowerCase())
            );
            if (!typeMatch) {
              return false;
            }
          }

          if (selectedAvailability.length > 0) {
            if (!selectedAvailability.includes(material.availability_status || "")) {
              return false;
            }
          }

          return true;
        });
      }

      setMaterials(results);
    } catch (error: any) {
      console.error("Failed to load materials:", error);
      console.error("Error response:", error.response);
      setMaterials([]);
      toast({
        title: "Error",
        description: error.response?.data?.detail || "Failed to load materials",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
  };

  const handleGenreToggle = (genreName: string) => {
    setSelectedGenres(prev => 
      prev.includes(genreName)
        ? prev.filter(g => g !== genreName)
        : [...prev, genreName]
    );
  };

  const handleMaterialTypeToggle = (type: string) => {
    setSelectedMaterialTypes(prev => 
      prev.includes(type)
        ? prev.filter(t => t !== type)
        : [...prev, type]
    );
  };

  const handleAvailabilityToggle = (availability: string) => {
    setSelectedAvailability(prev => 
      prev.includes(availability)
        ? prev.filter(a => a !== availability)
        : [...prev, availability]
    );
  };

  const handleSortChange = (value: string) => {
    setSortBy(value);
  };

  const materialTypeMap: Record<string, string> = {
    "Book": "Books",
    "Audiobook": "Audiobooks",
    "DVD": "DVDs",
    "CD": "CDs",
    "Magazine": "Magazines",
    "Journal": "Journals",
  };

  const availableMaterialTypes = Array.isArray(materials) 
    ? Array.from(new Set(materials.map(m => m.material_type).filter(Boolean))) as string[]
    : [];

  return (
    <div className="min-h-screen bg-background">
      <PatronHeader />
      
      <div className="border-b bg-muted/30">
        <div className="container mx-auto px-4 py-8">
          <h1 className="text-4xl font-bold mb-4">Library Catalog</h1>
          <SearchBar 
            placeholder="Search by title, author, ISBN, or keyword..." 
            onSearch={handleSearch}
            showSuggestions={true}
          />
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        <div className="flex gap-6">
          {showFilters && (
            <aside className="w-64 flex-shrink-0">
              <Card>
                <CardContent className="p-6 space-y-6">
                  <div>
                    <h3 className="font-semibold mb-4">Availability</h3>
                    <div className="space-y-3">
                      <div className="flex items-center gap-2">
                        <Checkbox 
                          id="available" 
                          data-testid="checkbox-available"
                          checked={selectedAvailability.includes("available")}
                          onCheckedChange={() => handleAvailabilityToggle("available")}
                        />
                        <Label htmlFor="available" className="cursor-pointer">Available Now</Label>
                      </div>
                      <div className="flex items-center gap-2">
                        <Checkbox 
                          id="reserved" 
                          data-testid="checkbox-reserved"
                          checked={selectedAvailability.includes("reserved")}
                          onCheckedChange={() => handleAvailabilityToggle("reserved")}
                        />
                        <Label htmlFor="reserved" className="cursor-pointer">Reserved</Label>
                      </div>
                      <div className="flex items-center gap-2">
                        <Checkbox 
                          id="checked-out" 
                          data-testid="checkbox-checked-out"
                          checked={selectedAvailability.includes("checked-out")}
                          onCheckedChange={() => handleAvailabilityToggle("checked-out")}
                        />
                        <Label htmlFor="checked-out" className="cursor-pointer">Checked Out</Label>
                      </div>
                    </div>
                  </div>

                  <div>
                    <h3 className="font-semibold mb-4">Genre</h3>
                    <div className="space-y-3 max-h-64 overflow-y-auto">
                      {genres.map((genre) => (
                        <div key={genre.genre_id} className="flex items-center gap-2">
                          <Checkbox 
                            id={`genre-${genre.genre_id}`} 
                            data-testid={`checkbox-genre-${genre.genre_name.toLowerCase().replace(/\s+/g, '-')}`}
                            checked={selectedGenres.includes(genre.genre_name)}
                            onCheckedChange={() => handleGenreToggle(genre.genre_name)}
                          />
                          <Label htmlFor={`genre-${genre.genre_id}`} className="cursor-pointer">
                            {genre.genre_name}
                          </Label>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div>
                    <h3 className="font-semibold mb-4">Material Type</h3>
                    <div className="space-y-3">
                      {availableMaterialTypes.length > 0 ? (
                        availableMaterialTypes.map((type) => (
                          <div key={type} className="flex items-center gap-2">
                            <Checkbox 
                              id={`type-${type}`} 
                              data-testid={`checkbox-type-${type.toLowerCase()}`}
                              checked={selectedMaterialTypes.includes(type)}
                              onCheckedChange={() => handleMaterialTypeToggle(type)}
                            />
                            <Label htmlFor={`type-${type}`} className="cursor-pointer">
                              {materialTypeMap[type] || type}
                            </Label>
                          </div>
                        ))
                      ) : (
                        <div className="space-y-3">
                          <div className="flex items-center gap-2">
                            <Checkbox 
                              id="book" 
                              data-testid="checkbox-type-book"
                              checked={selectedMaterialTypes.includes("Book")}
                              onCheckedChange={() => handleMaterialTypeToggle("Book")}
                            />
                            <Label htmlFor="book" className="cursor-pointer">Books</Label>
                          </div>
                          <div className="flex items-center gap-2">
                            <Checkbox 
                              id="audiobook" 
                              data-testid="checkbox-type-audiobook"
                              checked={selectedMaterialTypes.includes("Audiobook")}
                              onCheckedChange={() => handleMaterialTypeToggle("Audiobook")}
                            />
                            <Label htmlFor="audiobook" className="cursor-pointer">Audiobooks</Label>
                          </div>
                          <div className="flex items-center gap-2">
                            <Checkbox 
                              id="dvd" 
                              data-testid="checkbox-type-dvd"
                              checked={selectedMaterialTypes.includes("DVD")}
                              onCheckedChange={() => handleMaterialTypeToggle("DVD")}
                            />
                            <Label htmlFor="dvd" className="cursor-pointer">DVDs</Label>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            </aside>
          )}

          <div className="flex-1">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-4">
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => setShowFilters(!showFilters)}
                  data-testid="button-toggle-filters"
                >
                  <SlidersHorizontal className="h-5 w-5" />
                </Button>
                <p className="text-sm text-muted-foreground">
                  {loading ? "Loading..." : `Showing ${Array.isArray(materials) ? materials.length : 0} result${Array.isArray(materials) && materials.length !== 1 ? "s" : ""}`}
                </p>
              </div>

              <div className="flex items-center gap-4">
                <Select value={sortBy} onValueChange={handleSortChange}>
                  <SelectTrigger className="w-48" data-testid="select-sort">
                    <SelectValue placeholder="Sort by" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="relevance">Relevance</SelectItem>
                    <SelectItem value="title">Title A-Z</SelectItem>
                    <SelectItem value="author">Author A-Z</SelectItem>
                    <SelectItem value="newest">Newest First</SelectItem>
                  </SelectContent>
                </Select>

                <div className="flex gap-1 border rounded-md">
                  <Button
                    variant={viewMode === "grid" ? "default" : "ghost"}
                    size="icon"
                    onClick={() => setViewMode("grid")}
                    data-testid="button-view-grid"
                  >
                    <Grid3x3 className="h-4 w-4" />
                  </Button>
                  <Button
                    variant={viewMode === "list" ? "default" : "ghost"}
                    size="icon"
                    onClick={() => setViewMode("list")}
                    data-testid="button-view-list"
                  >
                    <List className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </div>

            {loading ? (
              <div className="text-center py-12">
                <p className="text-muted-foreground">Loading materials...</p>
              </div>
            ) : Array.isArray(materials) && materials.length > 0 ? (
              <div className={viewMode === "grid" ? "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6" : "space-y-4"}>
                {materials.map((material) => {
                  const availability = material.availability_status === "unavailable" 
                    ? "checked-out" 
                    : (material.availability_status || "available");
                  
                  return (
                    <div 
                      key={material.material_id}
                      onClick={() => setLocation(`/catalog/${material.material_id}`)}
                      className="cursor-pointer hover:shadow-lg transition-shadow"
                    >
                      <BookCard
                        id={material.material_id}
                        title={material.title}
                        author={material.authors || "Unknown Author"}
                        availability={availability as "available" | "reserved" | "checked-out"}
                        genre={material.genres?.split(", ")[0]}
                      />
                    </div>
                  );
                })}
              </div>
            ) : (
              <div className="text-center py-12">
                <p className="text-muted-foreground">No materials found. Try adjusting your filters.</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
