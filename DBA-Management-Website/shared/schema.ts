import { sql } from "drizzle-orm";
import { pgTable, text, varchar, integer, numeric, timestamp, boolean, primaryKey, unique } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

// ============================================================================
// AUTHENTICATION & AUTHORIZATION TABLES
// ============================================================================

export const users = pgTable("users", {
  userId: integer("user_id").primaryKey().generatedAlwaysAsIdentity(),
  username: varchar("username", { length: 50 }).notNull().unique(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  passwordHash: varchar("password_hash", { length: 255 }).notNull(),
  firstName: varchar("first_name", { length: 50 }),
  lastName: varchar("last_name", { length: 50 }),
  isActive: boolean("is_active").default(true).notNull(),
  accountLocked: boolean("account_locked").default(false).notNull(),
  lastLogin: timestamp("last_login"),
  lastPasswordChange: timestamp("last_password_change").defaultNow(),
  createdDate: timestamp("created_date").defaultNow().notNull(),
});

export const roles = pgTable("roles", {
  roleId: integer("role_id").primaryKey().generatedAlwaysAsIdentity(),
  roleCode: varchar("role_code", { length: 30 }).notNull().unique(),
  roleName: varchar("role_name", { length: 50 }).notNull(),
  roleDescription: varchar("role_description", { length: 500 }),
  isActive: boolean("is_active").default(true).notNull(),
  createdDate: timestamp("created_date").defaultNow(),
});

export const permissions = pgTable("permissions", {
  permissionId: integer("permission_id").primaryKey().generatedAlwaysAsIdentity(),
  permissionCode: varchar("permission_code", { length: 50 }).notNull().unique(),
  permissionName: varchar("permission_name", { length: 100 }).notNull(),
  permissionDescription: varchar("permission_description", { length: 500 }),
  permissionCategory: varchar("permission_category", { length: 50 }).notNull(),
  permissionResource: varchar("permission_resource", { length: 50 }),
  action: varchar("action", { length: 30 }),
  isActive: boolean("is_active").default(true).notNull(),
  createdDate: timestamp("created_date").defaultNow(),
});

export const userRoles = pgTable("user_roles", {
  userId: integer("user_id").notNull().references(() => users.userId, { onDelete: 'cascade' }),
  roleId: integer("role_id").notNull().references(() => roles.roleId),
  assignedDate: timestamp("assigned_date").defaultNow().notNull(),
  assignedByUserId: integer("assigned_by_user_id").references(() => users.userId),
  expiryDate: timestamp("expiry_date"),
  isActive: boolean("is_active").default(true).notNull(),
}, (table) => ({
  pk: primaryKey({ columns: [table.userId, table.roleId] })
}));

export const rolePermissions = pgTable("role_permissions", {
  roleId: integer("role_id").notNull().references(() => roles.roleId, { onDelete: 'cascade' }),
  permissionId: integer("permission_id").notNull().references(() => permissions.permissionId),
  grantedDate: timestamp("granted_date").defaultNow().notNull(),
  grantedByUserId: integer("granted_by_user_id").references(() => users.userId),
}, (table) => ({
  pk: primaryKey({ columns: [table.roleId, table.permissionId] })
}));

// ============================================================================
// LIBRARY OPERATIONAL TABLES
// ============================================================================

export const libraries = pgTable("libraries", {
  libraryId: integer("library_id").primaryKey().generatedAlwaysAsIdentity(),
  libraryName: varchar("library_name", { length: 150 }).notNull().unique(),
  establishedYear: integer("established_year"),
  headquartersAddress: varchar("headquarters_address", { length: 200 }),
  phone: varchar("phone", { length: 20 }),
  email: varchar("email", { length: 100 }),
  website: varchar("website", { length: 200 }),
  libraryDescription: varchar("library_description", { length: 500 }),
  createdDate: timestamp("created_date").defaultNow(),
});

export const branches = pgTable("branches", {
  branchId: integer("branch_id").primaryKey().generatedAlwaysAsIdentity(),
  libraryId: integer("library_id").notNull().references(() => libraries.libraryId),
  branchName: varchar("branch_name", { length: 100 }).notNull(),
  address: varchar("address", { length: 200 }).notNull(),
  phone: varchar("phone", { length: 20 }),
  email: varchar("email", { length: 100 }),
  openingHours: varchar("opening_hours", { length: 100 }),
  branchCapacity: integer("branch_capacity").default(50),
  createdDate: timestamp("created_date").defaultNow(),
}, (table) => ({
  uniqueBranchPerLibrary: unique().on(table.libraryId, table.branchName)
}));

export const patrons = pgTable("patrons", {
  patronId: integer("patron_id").primaryKey().generatedAlwaysAsIdentity(),
  userId: integer("user_id").references(() => users.userId, { onDelete: 'set null' }).unique(),
  cardNumber: varchar("card_number", { length: 20 }).notNull().unique(),
  firstName: varchar("first_name", { length: 50 }).notNull(),
  lastName: varchar("last_name", { length: 50 }).notNull(),
  email: varchar("email", { length: 100 }).unique(),
  phone: varchar("phone", { length: 20 }),
  address: varchar("address", { length: 200 }),
  dateOfBirth: timestamp("date_of_birth"),
  membershipType: varchar("membership_type", { length: 20 }).default('Standard'),
  registrationDate: timestamp("registration_date").defaultNow().notNull(),
  membershipExpiry: timestamp("membership_expiry").notNull(),
  registeredBranchId: integer("registered_branch_id").notNull().references(() => branches.branchId),
  accountStatus: varchar("account_status", { length: 20 }).default('Active'),
  totalFinesOwed: numeric("total_fines_owed", { precision: 10, scale: 2 }).default('0'),
  maxBorrowLimit: integer("max_borrow_limit").default(10),
});

export const staff = pgTable("staff", {
  staffId: integer("staff_id").primaryKey().generatedAlwaysAsIdentity(),
  userId: integer("user_id").references(() => users.userId, { onDelete: 'set null' }).unique(),
  employeeNumber: varchar("employee_number", { length: 20 }).notNull().unique(),
  firstName: varchar("first_name", { length: 50 }).notNull(),
  lastName: varchar("last_name", { length: 50 }).notNull(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  phone: varchar("phone", { length: 20 }),
  staffRole: varchar("staff_role", { length: 30 }).notNull(),
  branchId: integer("branch_id").notNull().references(() => branches.branchId),
  hireDate: timestamp("hire_date").defaultNow().notNull(),
  salary: numeric("salary", { precision: 10, scale: 2 }),
  isActive: boolean("is_active").default(true),
});

export const publishers = pgTable("publishers", {
  publisherId: integer("publisher_id").primaryKey().generatedAlwaysAsIdentity(),
  publisherName: varchar("publisher_name", { length: 150 }).notNull().unique(),
  country: varchar("country", { length: 100 }),
  website: varchar("website", { length: 200 }),
  email: varchar("email", { length: 100 }),
  foundedYear: integer("founded_year"),
});

export const authors = pgTable("authors", {
  authorId: integer("author_id").primaryKey().generatedAlwaysAsIdentity(),
  firstName: varchar("first_name", { length: 100 }).notNull(),
  lastName: varchar("last_name", { length: 100 }),
  biography: text("biography"),
  dateOfBirth: timestamp("date_of_birth"),
  nationality: varchar("nationality", { length: 100 }),
});

export const genres = pgTable("genres", {
  genreId: integer("genre_id").primaryKey().generatedAlwaysAsIdentity(),
  genreName: varchar("genre_name", { length: 100 }).notNull().unique(),
  genreDescription: varchar("genre_description", { length: 500 }),
});

export const materials = pgTable("materials", {
  materialId: integer("material_id").primaryKey().generatedAlwaysAsIdentity(),
  isbn: varchar("isbn", { length: 20 }).unique(),
  title: varchar("title", { length: 255 }).notNull(),
  subtitle: varchar("subtitle", { length: 255 }),
  publisherId: integer("publisher_id").references(() => publishers.publisherId),
  publicationYear: integer("publication_year"),
  edition: varchar("edition", { length: 50 }),
  language: varchar("language", { length: 50 }).default('English'),
  pages: integer("pages"),
  materialType: varchar("material_type", { length: 30 }).notNull().default('Book'),
  description: text("description"),
  coverImageUrl: varchar("cover_image_url", { length: 500 }),
  createdDate: timestamp("created_date").defaultNow(),
});

export const materialAuthors = pgTable("material_authors", {
  materialId: integer("material_id").notNull().references(() => materials.materialId, { onDelete: 'cascade' }),
  authorId: integer("author_id").notNull().references(() => authors.authorId),
  authorOrder: integer("author_order").default(1),
}, (table) => ({
  pk: primaryKey({ columns: [table.materialId, table.authorId] })
}));

export const materialGenres = pgTable("material_genres", {
  materialId: integer("material_id").notNull().references(() => materials.materialId, { onDelete: 'cascade' }),
  genreId: integer("genre_id").notNull().references(() => genres.genreId),
}, (table) => ({
  pk: primaryKey({ columns: [table.materialId, table.genreId] })
}));

export const copies = pgTable("copies", {
  copyId: integer("copy_id").primaryKey().generatedAlwaysAsIdentity(),
  materialId: integer("material_id").notNull().references(() => materials.materialId, { onDelete: 'cascade' }),
  branchId: integer("branch_id").notNull().references(() => branches.branchId),
  barcode: varchar("barcode", { length: 50 }).notNull().unique(),
  copyStatus: varchar("copy_status", { length: 20 }).default('Available'),
  condition: varchar("condition", { length: 20 }).default('Good'),
  location: varchar("location", { length: 100 }),
  acquiredDate: timestamp("acquired_date").defaultNow(),
  lastInventoryDate: timestamp("last_inventory_date"),
});

export const loans = pgTable("loans", {
  loanId: integer("loan_id").primaryKey().generatedAlwaysAsIdentity(),
  copyId: integer("copy_id").notNull().references(() => copies.copyId),
  patronId: integer("patron_id").notNull().references(() => patrons.patronId),
  checkoutDate: timestamp("checkout_date").defaultNow().notNull(),
  dueDate: timestamp("due_date").notNull(),
  returnDate: timestamp("return_date"),
  renewalCount: integer("renewal_count").default(0),
  loanStatus: varchar("loan_status", { length: 20 }).default('Active'),
  checkedOutBy: integer("checked_out_by").references(() => staff.staffId),
  returnedTo: integer("returned_to").references(() => staff.staffId),
});

export const reservations = pgTable("reservations", {
  reservationId: integer("reservation_id").primaryKey().generatedAlwaysAsIdentity(),
  materialId: integer("material_id").notNull().references(() => materials.materialId),
  patronId: integer("patron_id").notNull().references(() => patrons.patronId),
  reservationDate: timestamp("reservation_date").defaultNow().notNull(),
  expiryDate: timestamp("expiry_date"),
  queuePosition: integer("queue_position"),
  reservationStatus: varchar("reservation_status", { length: 20 }).default('Pending'),
  notifiedDate: timestamp("notified_date"),
  fulfilledDate: timestamp("fulfilled_date"),
});

export const fines = pgTable("fines", {
  fineId: integer("fine_id").primaryKey().generatedAlwaysAsIdentity(),
  loanId: integer("loan_id").references(() => loans.loanId),
  patronId: integer("patron_id").notNull().references(() => patrons.patronId),
  fineAmount: numeric("fine_amount", { precision: 10, scale: 2 }).notNull(),
  fineReason: varchar("fine_reason", { length: 200 }).notNull(),
  fineDate: timestamp("fine_date").defaultNow().notNull(),
  fineStatus: varchar("fine_status", { length: 20 }).default('Pending'),
  paidDate: timestamp("paid_date"),
  paymentMethod: varchar("payment_method", { length: 50 }),
  waivedBy: integer("waived_by").references(() => staff.staffId),
  waivedReason: varchar("waived_reason", { length: 200 }),
});

// ============================================================================
// INSERT SCHEMAS
// ============================================================================

export const insertUserSchema = createInsertSchema(users).omit({ userId: true, createdDate: true, lastPasswordChange: true, lastLogin: true });
export const insertRoleSchema = createInsertSchema(roles).omit({ roleId: true, createdDate: true });
export const insertPermissionSchema = createInsertSchema(permissions).omit({ permissionId: true, createdDate: true });
export const insertLibrarySchema = createInsertSchema(libraries).omit({ libraryId: true, createdDate: true });
export const insertBranchSchema = createInsertSchema(branches).omit({ branchId: true, createdDate: true });
export const insertPatronSchema = createInsertSchema(patrons).omit({ patronId: true, registrationDate: true });
export const insertStaffSchema = createInsertSchema(staff).omit({ staffId: true, hireDate: true });
export const insertPublisherSchema = createInsertSchema(publishers).omit({ publisherId: true });
export const insertAuthorSchema = createInsertSchema(authors).omit({ authorId: true });
export const insertGenreSchema = createInsertSchema(genres).omit({ genreId: true });
export const insertMaterialSchema = createInsertSchema(materials).omit({ materialId: true, createdDate: true });
export const insertCopySchema = createInsertSchema(copies).omit({ copyId: true, acquiredDate: true });
export const insertLoanSchema = createInsertSchema(loans).omit({ loanId: true, checkoutDate: true });
export const insertReservationSchema = createInsertSchema(reservations).omit({ reservationId: true, reservationDate: true });
export const insertFineSchema = createInsertSchema(fines).omit({ fineId: true, fineDate: true });

// ============================================================================
// TYPES
// ============================================================================

export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;
export type Role = typeof roles.$inferSelect;
export type Permission = typeof permissions.$inferSelect;
export type Library = typeof libraries.$inferSelect;
export type Branch = typeof branches.$inferSelect;
export type Patron = typeof patrons.$inferSelect;
export type Staff = typeof staff.$inferSelect;
export type Publisher = typeof publishers.$inferSelect;
export type Author = typeof authors.$inferSelect;
export type Genre = typeof genres.$inferSelect;
export type Material = typeof materials.$inferSelect;
export type Copy = typeof copies.$inferSelect;
export type Loan = typeof loans.$inferSelect;
export type Reservation = typeof reservations.$inferSelect;
export type Fine = typeof fines.$inferSelect;