import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { DollarSign } from "lucide-react";

export interface FineCardProps {
  id: number;
  bookTitle: string;
  amount: number;
  reason: string;
  dateIssued: Date;
  status: 'pending' | 'paid' | 'waived' | "unpaid";
  onPay?: () => void;
}

export function FineCard({ id, bookTitle, amount, reason, dateIssued, status, onPay }: FineCardProps) {
  const statusColors = {
    pending: "bg-yellow-600 dark:bg-yellow-700",
    paid: "bg-green-600 dark:bg-green-700",
    waived: "bg-muted dark:bg-muted",
    unpaid: "bg-red-600 dark:bg-red-700"
  };

  const statusLabels = {
    pending: "Pending",
    paid: "Paid",
    waived: "Waived",
    unpaid: "unpaid"
  };

  return (
    <Card data-testid={`card-fine-${id}`}>
      <CardContent className="p-6">
        <div className="flex items-start justify-between gap-4 mb-4">
          <div className="space-y-1 flex-1">
            <h3 className="font-semibold" data-testid={`text-fine-book-${id}`}>{bookTitle}</h3>
            <p className="text-sm text-muted-foreground">{reason}</p>
            <p className="text-xs text-muted-foreground">Issued: {dateIssued.toLocaleDateString()}</p>
          </div>
          <Badge className={statusColors[status]}>
            {statusLabels[status]}
          </Badge>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <DollarSign className="h-5 w-5 text-muted-foreground" />
            <span className="text-2xl font-semibold" data-testid={`text-fine-amount-${id}`}>
              ${amount.toFixed(2)}
            </span>
          </div>

          {status === 'pending' && (
            <Button 
              onClick={() => {
                console.log(`Paying fine ${id}`);
                onPay?.();
              }}
              data-testid={`button-pay-fine-${id}`}
            >
              Pay Now
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}