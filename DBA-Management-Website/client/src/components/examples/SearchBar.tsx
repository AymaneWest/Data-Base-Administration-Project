import { SearchBar } from '../SearchBar';

export default function SearchBarExample() {
  return (
    <div className="max-w-2xl mx-auto p-8 space-y-6">
      <SearchBar onSearch={(q) => console.log('Searched:', q)} />
      <SearchBar 
        placeholder="Search for patrons..." 
        onSearch={(q) => console.log('Patron search:', q)} 
      />
    </div>
  );
}