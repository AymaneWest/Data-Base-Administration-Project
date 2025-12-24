import { StaffSidebar } from "@/components/StaffSidebar";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { ThemeToggle } from "@/components/ThemeToggle";
import { Package, Search, Home } from "lucide-react";
import { useState } from "react";
import * as api from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useLocation } from "wouter";

export default function Catalog() {
    const { toast } = useToast();
    const [, setLocation] = useLocation();
    const [searchTerm, setSearchTerm] = useState('');
    const [searchResults, setSearchResults] = useState<any[]>([]);
    const [loading, setLoading] = useState(false);

    // Add material form state
    const [materialForm, setMaterialForm] = useState({
        title: '',
        subtitle: '',
        material_type: 'Book',
        isbn: '',
        publication_year: '',
        publisher_id: 1,
        language: 'English',
        pages: '',
        description: '',
        total_copies: 1
    });
    const [adding, setAdding] = useState(false);

    const handleSearch = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            const response = await api.browseMaterials({ search: searchTerm });
            setSearchResults(response.data || []);

            toast({
                title: "Search Complete",
                description: `Found ${response.data?.length || 0} materials`,
            });
        } catch (error: any) {
            toast({
                title: "Search Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleAddMaterial = async (e: React.FormEvent) => {
        e.preventDefault();
        setAdding(true);

        try {
            const response = await api.addMaterial({
                ...materialForm,
                publication_year: parseInt(materialForm.publication_year),
                pages: parseInt(materialForm.pages),
                total_copies: parseInt(materialForm.total_copies.toString())
            });

            toast({
                title: "Material Added",
                description: `Material added successfully with ID: ${response.data?.material_id}`,
            });

            // Reset form
            setMaterialForm({
                title: '',
                subtitle: '',
                material_type: 'Book',
                isbn: '',
                publication_year: '',
                publisher_id: 1,
                language: 'English',
                pages: '',
                description: '',
                total_copies: 1
            });
        } catch (error: any) {
            toast({
                title: "Add Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setAdding(false);
        }
    };

    return (
        <div className="flex h-screen bg-background">
            <StaffSidebar />

            <div className="flex-1 flex flex-col overflow-hidden">
                <header className="border-b bg-background p-4 flex items-center justify-between">
                    <div>
                        <h1 className="text-2xl font-bold">Catalog</h1>
                        <p className="text-sm text-muted-foreground">Browse and manage library materials</p>
                    </div>
                    <div className="flex items-center gap-2">
                        <Button variant="outline" size="icon" onClick={() => setLocation('/')} title="Go to Home">
                            <Home className="h-5 w-5" />
                        </Button>
                        <ThemeToggle />
                    </div>
                </header>

                <main className="flex-1 overflow-y-auto p-8">
                    <Tabs defaultValue="search" className="space-y-6">
                        <TabsList>
                            <TabsTrigger value="search">Search Catalog</TabsTrigger>
                            <TabsTrigger value="add">Add Material</TabsTrigger>
                        </TabsList>

                        <TabsContent value="search">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center gap-2">
                                        <Search className="h-5 w-5" />
                                        Search Catalog
                                    </CardTitle>
                                    <CardDescription>
                                        Search for materials in the library catalog
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleSearch} className="space-y-4">
                                        <div className="flex gap-4">
                                            <Input
                                                placeholder="Search by title, author, ISBN..."
                                                value={searchTerm}
                                                onChange={(e) => setSearchTerm(e.target.value)}
                                                className="flex-1"
                                            />
                                            <Button type="submit" disabled={loading}>
                                                {loading ? 'Searching...' : 'Search'}
                                            </Button>
                                        </div>
                                    </form>

                                    {searchResults.length > 0 && (
                                        <div className="mt-6">
                                            <h3 className="font-semibold mb-4">Results ({searchResults.length})</h3>
                                            <div className="border rounded-lg">
                                                <Table>
                                                    <TableHeader>
                                                        <TableRow>
                                                            <TableHead className="w-[80px]">Image</TableHead>
                                                            <TableHead>Title</TableHead>
                                                            <TableHead>Author(s)</TableHead>
                                                            <TableHead>ISBN</TableHead>
                                                            <TableHead>Type</TableHead>
                                                            <TableHead>Available</TableHead>
                                                            <TableHead>Total</TableHead>
                                                        </TableRow>
                                                    </TableHeader>
                                                    <TableBody>
                                                        {searchResults.map((material, index) => (
                                                            <TableRow key={index}>
                                                                <TableCell>
                                                                    <div className="h-[60px] w-[40px] rounded overflow-hidden bg-muted">
                                                                        <img
                                                                            src={material.cover_image || "/covers/placeholder.jpg"}
                                                                            alt={material.title}
                                                                            className="h-full w-full object-cover"
                                                                            onError={(e) => e.currentTarget.src = "/covers/placeholder.jpg"}
                                                                        />
                                                                    </div>
                                                                </TableCell>
                                                                <TableCell className="font-medium">{material.title}</TableCell>
                                                                <TableCell>{material.authors || 'N/A'}</TableCell>
                                                                <TableCell>{material.isbn || 'N/A'}</TableCell>
                                                                <TableCell>{material.material_type}</TableCell>
                                                                <TableCell>{material.available_copies || 0}</TableCell>
                                                                <TableCell>{material.total_copies || 0}</TableCell>
                                                            </TableRow>
                                                        ))}
                                                    </TableBody>
                                                </Table>
                                            </div>
                                        </div>
                                    )}
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="add">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center gap-2">
                                        <Package className="h-5 w-5" />
                                        Add New Material
                                    </CardTitle>
                                    <CardDescription>
                                        Add a new item to the library catalog
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleAddMaterial} className="space-y-4">
                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="title">Title *</Label>
                                                <Input
                                                    id="title"
                                                    value={materialForm.title}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, title: e.target.value })}
                                                    required
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="subtitle">Subtitle</Label>
                                                <Input
                                                    id="subtitle"
                                                    value={materialForm.subtitle}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, subtitle: e.target.value })}
                                                />
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-3 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="material_type">Material Type *</Label>
                                                <Input
                                                    id="material_type"
                                                    value={materialForm.material_type}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, material_type: e.target.value })}
                                                    required
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="isbn">ISBN</Label>
                                                <Input
                                                    id="isbn"
                                                    value={materialForm.isbn}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, isbn: e.target.value })}
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="publication_year">Publication Year</Label>
                                                <Input
                                                    id="publication_year"
                                                    type="number"
                                                    value={materialForm.publication_year}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, publication_year: e.target.value })}
                                                />
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-3 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="publisher_id">Publisher ID *</Label>
                                                <Input
                                                    id="publisher_id"
                                                    type="number"
                                                    value={materialForm.publisher_id}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, publisher_id: parseInt(e.target.value) })}
                                                    required
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="language">Language</Label>
                                                <Input
                                                    id="language"
                                                    value={materialForm.language}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, language: e.target.value })}
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="pages">Pages</Label>
                                                <Input
                                                    id="pages"
                                                    type="number"
                                                    value={materialForm.pages}
                                                    onChange={(e) => setMaterialForm({ ...materialForm, pages: e.target.value })}
                                                />
                                            </div>
                                        </div>

                                        <div className="space-y-2">
                                            <Label htmlFor="description">Description</Label>
                                            <Textarea
                                                id="description"
                                                value={materialForm.description}
                                                onChange={(e) => setMaterialForm({ ...materialForm, description: e.target.value })}
                                                rows={4}
                                            />
                                        </div>

                                        <div className="space-y-2">
                                            <Label htmlFor="total_copies">Total Copies *</Label>
                                            <Input
                                                id="total_copies"
                                                type="number"
                                                value={materialForm.total_copies}
                                                onChange={(e) => setMaterialForm({ ...materialForm, total_copies: parseInt(e.target.value) })}
                                                required
                                                min="1"
                                            />
                                        </div>

                                        <Button type="submit" disabled={adding} className="w-full">
                                            <Package className="mr-2 h-4 w-4" />
                                            {adding ? 'Adding Material...' : 'Add Material'}
                                        </Button>
                                    </form>
                                </CardContent>
                            </Card>
                        </TabsContent>
                    </Tabs>
                </main>
            </div>
        </div>
    );
}
