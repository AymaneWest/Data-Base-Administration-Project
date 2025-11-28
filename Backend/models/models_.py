from typing import Optional
import datetime
import decimal

from sqlalchemy import CheckConstraint, Computed, DateTime, Enum, ForeignKeyConstraint, Index, PrimaryKeyConstraint, Text, VARCHAR, text
from sqlalchemy.dialects.oracle import NUMBER
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass


class Authors(Base):
    __tablename__ = 'authors'
    __table_args__ = (
        PrimaryKeyConstraint('author_id', name='sys_c0011471'),
        {'comment': 'Authors and creators of library materials',
     'schema': 'C##PROJET_DB'}
    )

    author_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    last_name: Mapped[str] = mapped_column(VARCHAR(50), nullable=False)
    first_name: Mapped[Optional[str]] = mapped_column(VARCHAR(50))
    full_name: Mapped[Optional[str]] = mapped_column(VARCHAR(150), Computed('"FIRST_NAME"||\' \'||"LAST_NAME"'))
    biography: Mapped[Optional[str]] = mapped_column(Text)
    birth_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    death_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    nationality: Mapped[Optional[str]] = mapped_column(VARCHAR(50))
    website: Mapped[Optional[str]] = mapped_column(VARCHAR(100))

    material_authors: Mapped[list['MaterialAuthors']] = relationship('MaterialAuthors', back_populates='author')


class Genres(Base):
    __tablename__ = 'genres'
    __table_args__ = (
        PrimaryKeyConstraint('genre_id', name='sys_c0011473'),
        Index('sys_c0011474', 'genre_name', unique=True),
        {'comment': 'Subject classifications and genres for materials',
     'schema': 'C##PROJET_DB'}
    )

    genre_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    genre_name: Mapped[str] = mapped_column(VARCHAR(50), nullable=False)
    genre_description: Mapped[Optional[str]] = mapped_column(VARCHAR(500))

    material_genres: Mapped[list['MaterialGenres']] = relationship('MaterialGenres', back_populates='genre')


class Libraries(Base):
    __tablename__ = 'libraries'
    __table_args__ = (
        PrimaryKeyConstraint('library_id', name='sys_c0011426'),
        Index('sys_c0011427', 'library_name', unique=True),
        {'comment': 'Parent library organizations that own and manage one or more '
                'branches.',
     'schema': 'C##PROJET_DB'}
    )

    library_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Primary key identifying each library organization.')
    library_name: Mapped[str] = mapped_column(VARCHAR(150), nullable=False, comment='Official name of the library system (e.g., "Library X").')
    established_year: Mapped[Optional[float]] = mapped_column(NUMBER(4, 0, False), comment='The year when the library organization was established.')
    headquarters_address: Mapped[Optional[str]] = mapped_column(VARCHAR(200), comment='Main office address of the library organization.')
    phone: Mapped[Optional[str]] = mapped_column(VARCHAR(20), comment='Global contact phone number for the organization.')
    email: Mapped[Optional[str]] = mapped_column(VARCHAR(100), comment='Global contact email for the organization.')
    website: Mapped[Optional[str]] = mapped_column(VARCHAR(200), comment='Website URL of the library system.')
    library_description: Mapped[Optional[str]] = mapped_column(VARCHAR(500), comment='Short description or mission statement of the library.')
    created_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, server_default=text('SYSDATE                         -- Timestamp when the record was created\n'), comment='Record creation timestamp, defaults to current system date.')

    branches: Mapped[list['Branches']] = relationship('Branches', back_populates='library')


class LoginAttempts(Base):
    __tablename__ = 'login_attempts'
    __table_args__ = (
        PrimaryKeyConstraint('attempt_id', name='sys_c0011424'),
        {'comment': 'Tracks login attempts to detect and prevent brute-force attacks',
     'schema': 'C##PROJET_DB'}
    )

    attempt_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Unique login attempt identifier')
    username: Mapped[str] = mapped_column(VARCHAR(50), nullable=False)
    attempt_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    login_result: Mapped[str] = mapped_column(Enum('SUCCESS', 'FAILURE'), nullable=False, comment='SUCCESS or FAILURE of login attempt')
    failure_reason: Mapped[Optional[str]] = mapped_column(VARCHAR(200))


class Permissions(Base):
    __tablename__ = 'permissions'
    __table_args__ = (
        CheckConstraint("permission_category IN \n        ('Circulation', 'Catalog', 'Patrons', 'Reports', 'Administration', 'Fines', 'System')", name='chk_permission_category'),
        PrimaryKeyConstraint('permission_id', name='sys_c0011385'),
        Index('sys_c0011386', 'permission_code', unique=True),
        {'comment': 'Granular permissions that define which actions users or roles can '
                'perform',
     'schema': 'C##PROJET_DB'}
    )

    permission_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Primary key - unique identifier for each permission')
    permission_code: Mapped[str] = mapped_column(VARCHAR(50), nullable=False, comment='Unique internal code (e.g., VIEW_REPORTS)')
    permission_name: Mapped[str] = mapped_column(VARCHAR(100), nullable=False, comment='Human-readable name of the permission')
    permission_category: Mapped[str] = mapped_column(VARCHAR(50), nullable=False, comment='Functional area (Circulation, Catalog, etc.)')
    permission_description: Mapped[Optional[str]] = mapped_column(VARCHAR(500), comment='Detailed description of what this permission allows')
    permission_resource: Mapped[Optional[str]] = mapped_column(VARCHAR(50), comment='Resource affected by this permission (e.g., Book, Fine)')
    action: Mapped[Optional[str]] = mapped_column(VARCHAR(30), comment='Action type (Create, Read, Update, Delete)')
    is_active: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'Y'"), comment='Y = Active permission, N = Disabled or legacy permission')
    created_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, server_default=text('SYSDATE'), comment='Date when this permission was defined')

    role_permissions: Mapped[list['RolePermissions']] = relationship('RolePermissions', back_populates='permission')


class Publishers(Base):
    __tablename__ = 'publishers'
    __table_args__ = (
        PrimaryKeyConstraint('publisher_id', name='sys_c0011468'),
        Index('sys_c0011469', 'publisher_name', unique=True),
        {'comment': 'Publishing companies that publish materials',
     'schema': 'C##PROJET_DB'}
    )

    publisher_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    publisher_name: Mapped[str] = mapped_column(VARCHAR(100), nullable=False)
    country: Mapped[Optional[str]] = mapped_column(VARCHAR(50))
    website: Mapped[Optional[str]] = mapped_column(VARCHAR(100))
    contact_email: Mapped[Optional[str]] = mapped_column(VARCHAR(100))
    contact_phone: Mapped[Optional[str]] = mapped_column(VARCHAR(20))

    materials: Mapped[list['Materials']] = relationship('Materials', back_populates='publisher')


class Roles(Base):
    __tablename__ = 'roles'
    __table_args__ = (
        PrimaryKeyConstraint('role_id', name='sys_c0011378'),
        Index('sys_c0011379', 'role_code', unique=True),
        {'comment': 'System roles defining user categories and access privileges',
     'schema': 'C##PROJET_DB'}
    )

    role_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Primary key - unique identifier for each role')
    role_code: Mapped[str] = mapped_column(VARCHAR(30), nullable=False, comment='Unique code for the role (e.g., ADMIN, LIBR, MEMBER)')
    role_name: Mapped[str] = mapped_column(VARCHAR(50), nullable=False, comment='Descriptive name for the role')
    role_description: Mapped[Optional[str]] = mapped_column(VARCHAR(500), comment='Text description explaining the purpose of the role')
    is_active: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'Y'"), comment='Y = Active role, N = Deprecated or inactive role')
    created_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, server_default=text('SYSDATE'), comment='Date when the role record was created')

    role_permissions: Mapped[list['RolePermissions']] = relationship('RolePermissions', back_populates='role')
    user_roles: Mapped[list['UserRoles']] = relationship('UserRoles', back_populates='role')


class Users(Base):
    __tablename__ = 'users'
    __table_args__ = (
        PrimaryKeyConstraint('user_id', name='sys_c0011372'),
        Index('sys_c0011373', 'username', unique=True),
        Index('sys_c0011374', 'email', unique=True),
        {'comment': 'System users for authentication - includes staff, patrons, and '
                'administrators',
     'schema': 'C##PROJET_DB'}
    )

    user_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Primary key - unique identifier for each system user')
    username: Mapped[str] = mapped_column(VARCHAR(50), nullable=False, comment='Unique username used for system login')
    email: Mapped[str] = mapped_column(VARCHAR(100), nullable=False, comment='Unique user email used for contact and password recovery')
    password_hash: Mapped[str] = mapped_column(VARCHAR(255), nullable=False, comment='Hashed password for authentication - never store plain text')
    created_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '), comment='Account creation timestamp')
    first_name: Mapped[Optional[str]] = mapped_column(VARCHAR(50))
    last_name: Mapped[Optional[str]] = mapped_column(VARCHAR(50))
    is_active: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'Y'"), comment='Y = Active user, N = Inactive account')
    account_locked: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'N'"), comment='Y = Locked due to failed attempts, N = Normal access')
    last_login: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, comment='Timestamp of the last successful login')
    last_password_change: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, server_default=text('SYSDATE'), comment='Date when user last changed password')

    audit_log: Mapped[list['AuditLog']] = relationship('AuditLog', back_populates='user')
    password_history: Mapped[list['PasswordHistory']] = relationship('PasswordHistory', back_populates='user')
    role_permissions: Mapped[list['RolePermissions']] = relationship('RolePermissions', back_populates='granted_by_user')
    session_management: Mapped[list['SessionManagement']] = relationship('SessionManagement', back_populates='user')
    user_roles: Mapped[list['UserRoles']] = relationship('UserRoles', foreign_keys='[UserRoles.assigned_by_user_id]', back_populates='assigned_by_user')
    user_roles_: Mapped[list['UserRoles']] = relationship('UserRoles', foreign_keys='[UserRoles.user_id]', back_populates='user')
    patrons: Mapped[list['Patrons']] = relationship('Patrons', back_populates='user')
    staff: Mapped[list['Staff']] = relationship('Staff', back_populates='user')


class AuditLog(Base):
    __tablename__ = 'audit_log'
    __table_args__ = (
        CheckConstraint("action_type IN \n        ('LOGIN', 'LOGOUT', 'PERMISSION_DENIED', 'DATA_ACCESS', 'DATA_CREATE', 'DATA_UPDATE', 'DATA_DELETE', 'PASSWORD_CHANGE', 'PERMISSION_CHECK')", name='chk_action_type'),
        ForeignKeyConstraint(['user_id'], ['C##PROJET_DB.users.user_id'], ondelete='SET NULL', name='fk_audit_user'),
        PrimaryKeyConstraint('audit_id', name='sys_c0011407'),
        {'comment': 'Records all security events for compliance and troubleshooting',
     'schema': 'C##PROJET_DB'}
    )

    audit_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Unique audit event identifier')
    action_type: Mapped[str] = mapped_column(VARCHAR(50), nullable=False, comment='Type of action (LOGIN, LOGOUT, etc.)')
    status: Mapped[str] = mapped_column(Enum('SUCCESS', 'FAILURE'), nullable=False, comment='SUCCESS or FAILURE status of action')
    audit_timestamp: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    user_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), comment='User who triggered the event')
    resource_accessed: Mapped[Optional[str]] = mapped_column(VARCHAR(100))
    action_details: Mapped[Optional[str]] = mapped_column(VARCHAR(500))
    action_old_value: Mapped[Optional[str]] = mapped_column(VARCHAR(500))
    action_new_value: Mapped[Optional[str]] = mapped_column(VARCHAR(500))
    failure_reason: Mapped[Optional[str]] = mapped_column(VARCHAR(200))

    user: Mapped[Optional['Users']] = relationship('Users', back_populates='audit_log')


class Branches(Base):
    __tablename__ = 'branches'
    __table_args__ = (
        CheckConstraint('branch_capacity > 0', name='chk_branch_capacity'),
        ForeignKeyConstraint(['library_id'], ['C##PROJET_DB.libraries.library_id'], name='fk_branch_library'),
        PrimaryKeyConstraint('branch_id', name='sys_c0011432'),
        Index('uq_branch_name_per_library', 'library_id', 'branch_name', unique=True),
        {'comment': 'Physical locations (branches) of each library organization.',
     'schema': 'C##PROJET_DB'}
    )

    branch_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Primary key identifying each library branch.')
    library_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False, comment='Foreign key referencing LIBRARIES.library_id.')
    branch_name: Mapped[str] = mapped_column(VARCHAR(100), nullable=False, comment='Name of the specific branch within the library system.')
    address: Mapped[str] = mapped_column(VARCHAR(200), nullable=False, comment='Physical street address of the branch.')
    phone: Mapped[Optional[str]] = mapped_column(VARCHAR(20), comment='Branch contact phone number.')
    email: Mapped[Optional[str]] = mapped_column(VARCHAR(100), comment='Branch contact email address.')
    opening_hours: Mapped[Optional[str]] = mapped_column(VARCHAR(100), comment='Branch opening hours (e.g., 08:00–20:00).')
    branch_capacity: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), server_default=text('50'), comment='Maximum number of visitors/books the branch can handle at once.')
    created_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, server_default=text('SYSDATE'), comment='Date when the branch record was created.')

    library: Mapped['Libraries'] = relationship('Libraries', back_populates='branches')
    copies: Mapped[list['Copies']] = relationship('Copies', back_populates='branch')
    patrons: Mapped[list['Patrons']] = relationship('Patrons', back_populates='registered_branch')
    staff: Mapped[list['Staff']] = relationship('Staff', back_populates='branch')


class Materials(Base):
    __tablename__ = 'materials'
    __table_args__ = (
        CheckConstraint('available_copies <= total_copies', name='chk_copies_consistent'),
        CheckConstraint('available_copies <= total_copies', name='chk_copies_consistent'),
        CheckConstraint("material_type IN \n        ('Book', 'DVD', 'Magazine', 'E-book', 'Audiobook', 'Journal', 'Newspaper', 'CD', 'Game')", name='chk_material_type'),
        CheckConstraint('total_copies >= 0 AND available_copies >= 0', name='chk_copies_positive'),
        CheckConstraint('total_copies >= 0 AND available_copies >= 0', name='chk_copies_positive'),
        ForeignKeyConstraint(['publisher_id'], ['C##PROJET_DB.publishers.publisher_id'], name='fk_material_publisher'),
        PrimaryKeyConstraint('material_id', name='sys_c0011483'),
        {'comment': 'Catalog of all library materials including books, DVDs, journals, '
                'etc.',
     'schema': 'C##PROJET_DB'}
    )

    material_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    title: Mapped[str] = mapped_column(VARCHAR(200), nullable=False)
    material_type: Mapped[str] = mapped_column(VARCHAR(30), nullable=False, comment='Specifies type of material (Book, DVD, etc.)')
    date_added: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    subtitle: Mapped[Optional[str]] = mapped_column(VARCHAR(200))
    isbn: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    issn: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    publication_year: Mapped[Optional[float]] = mapped_column(NUMBER(4, 0, False))
    publisher_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    language: Mapped[Optional[str]] = mapped_column(VARCHAR(30), server_default=text("'English'"))
    edition: Mapped[Optional[str]] = mapped_column(VARCHAR(50))
    pages: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    description: Mapped[Optional[str]] = mapped_column(Text)
    dewey_decimal: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    total_copies: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), server_default=text('0'), comment='Total number of copies owned by the library')
    available_copies: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), server_default=text('0'), comment='Number of copies currently available to borrow')
    is_reference: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'N'"), comment='Y if item is reference-only (cannot be borrowed)')
    is_new_release: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'N'"), comment='Y if recently published or newly added')

    publisher: Mapped[Optional['Publishers']] = relationship('Publishers', back_populates='materials')
    copies: Mapped[list['Copies']] = relationship('Copies', back_populates='material')
    material_authors: Mapped[list['MaterialAuthors']] = relationship('MaterialAuthors', back_populates='material')
    material_genres: Mapped[list['MaterialGenres']] = relationship('MaterialGenres', back_populates='material')
    reservations: Mapped[list['Reservations']] = relationship('Reservations', back_populates='material')


class PasswordHistory(Base):
    __tablename__ = 'password_history'
    __table_args__ = (
        ForeignKeyConstraint(['user_id'], ['C##PROJET_DB.users.user_id'], ondelete='CASCADE', name='fk_pwd_history_user'),
        PrimaryKeyConstraint('history_id', name='sys_c0011418'),
        {'comment': 'Stores old password hashes to prevent password reuse',
     'schema': 'C##PROJET_DB'}
    )

    history_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Unique password history record identifier')
    user_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    old_password_hash: Mapped[str] = mapped_column(VARCHAR(255), nullable=False)
    changed_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))

    user: Mapped['Users'] = relationship('Users', back_populates='password_history')


class RolePermissions(Base):
    __tablename__ = 'role_permissions'
    __table_args__ = (
        ForeignKeyConstraint(['granted_by_user_id'], ['C##PROJET_DB.users.user_id'], name='fk_rp_granted_by'),
        ForeignKeyConstraint(['permission_id'], ['C##PROJET_DB.permissions.permission_id'], name='fk_rp_permission'),
        ForeignKeyConstraint(['role_id'], ['C##PROJET_DB.roles.role_id'], ondelete='CASCADE', name='fk_rp_role'),
        PrimaryKeyConstraint('role_id', 'permission_id', name='pk_role_permissions'),
        {'comment': 'Junction table linking roles with permissions they are granted',
     'schema': 'C##PROJET_DB'}
    )

    role_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Foreign key referencing ROLES(role_id)')
    permission_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Foreign key referencing PERMISSIONS(permission_id)')
    granted_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '), comment='Date when permission was granted to role')
    granted_by_user_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), comment='User who assigned this permission')

    granted_by_user: Mapped[Optional['Users']] = relationship('Users', back_populates='role_permissions')
    permission: Mapped['Permissions'] = relationship('Permissions', back_populates='role_permissions')
    role: Mapped['Roles'] = relationship('Roles', back_populates='role_permissions')


class SessionManagement(Base):
    __tablename__ = 'session_management'
    __table_args__ = (
        ForeignKeyConstraint(['user_id'], ['C##PROJET_DB.users.user_id'], ondelete='CASCADE', name='fk_session_user'),
        PrimaryKeyConstraint('session_id', name='sys_c0011413'),
        {'comment': 'Manages active user sessions and tracks who is currently logged '
                'in',
     'schema': 'C##PROJET_DB'}
    )

    session_id: Mapped[str] = mapped_column(VARCHAR(100), primary_key=True, comment='Unique session identifier token')
    user_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    login_time: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    last_activity_time: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    logout_time: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    session_status: Mapped[Optional[str]] = mapped_column(Enum('ACTIVE', 'EXPIRED', 'LOGGED_OUT'), server_default=text("'ACTIVE'"), comment='Current session state (ACTIVE, EXPIRED, LOGGED_OUT)')
    session_timeout_minutes: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), server_default=text('30'))

    user: Mapped['Users'] = relationship('Users', back_populates='session_management')


class UserRoles(Base):
    __tablename__ = 'user_roles'
    __table_args__ = (
        ForeignKeyConstraint(['assigned_by_user_id'], ['C##PROJET_DB.users.user_id'], name='fk_ur_assigned_by'),
        ForeignKeyConstraint(['role_id'], ['C##PROJET_DB.roles.role_id'], name='fk_ur_role'),
        ForeignKeyConstraint(['user_id'], ['C##PROJET_DB.users.user_id'], ondelete='CASCADE', name='fk_ur_user'),
        PrimaryKeyConstraint('user_id', 'role_id', name='pk_user_roles'),
        {'comment': 'Junction table - each user can have multiple roles assigned',
     'schema': 'C##PROJET_DB'}
    )

    user_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Foreign key referencing USERS(user_id)')
    role_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Foreign key referencing ROLES(role_id)')
    assigned_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '), comment='Date when role was assigned to user')
    assigned_by_user_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), comment='User who assigned this role')
    expiry_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, comment='Date when this role assignment expires')
    is_active: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'Y'"), comment='Y = Active assignment, N = Revoked or expired')

    assigned_by_user: Mapped[Optional['Users']] = relationship('Users', foreign_keys=[assigned_by_user_id], back_populates='user_roles')
    role: Mapped['Roles'] = relationship('Roles', back_populates='user_roles')
    user: Mapped['Users'] = relationship('Users', foreign_keys=[user_id], back_populates='user_roles_')


class Copies(Base):
    __tablename__ = 'copies'
    __table_args__ = (
        CheckConstraint("copy_condition IN \n        ('New', 'Excellent', 'Good', 'Fair', 'Poor', 'Damaged')", name='chk_copy_condition'),
        CheckConstraint("copy_status IN \n        ('Available', 'Checked Out', 'Reserved', 'In Transit', 'Lost', 'Damaged', 'Under Repair', 'Withdrawn')", name='chk_copy_status'),
        ForeignKeyConstraint(['branch_id'], ['C##PROJET_DB.branches.branch_id'], name='fk_copy_branch'),
        ForeignKeyConstraint(['material_id'], ['C##PROJET_DB.materials.material_id'], ondelete='CASCADE', name='fk_copy_material'),
        PrimaryKeyConstraint('copy_id', name='sys_c0011490'),
        Index('sys_c0011491', 'barcode', unique=True),
        {'comment': 'Physical or digital instances of materials that can be borrowed '
                'or referenced',
     'schema': 'C##PROJET_DB'}
    )

    copy_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    material_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    barcode: Mapped[str] = mapped_column(VARCHAR(50), nullable=False)
    branch_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    copy_condition: Mapped[Optional[str]] = mapped_column(VARCHAR(20), server_default=text("'Good'"), comment='Describes the physical condition of the copy')
    copy_status: Mapped[Optional[str]] = mapped_column(VARCHAR(30), server_default=text("'Available'"), comment='Current availability status of the copy')
    acquisition_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, server_default=text('SYSDATE'))
    acquisition_price: Mapped[Optional[decimal.Decimal]] = mapped_column(NUMBER(10, 2, True))
    last_maintenance_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)

    branch: Mapped['Branches'] = relationship('Branches', back_populates='copies')
    material: Mapped['Materials'] = relationship('Materials', back_populates='copies')
    loans: Mapped[list['Loans']] = relationship('Loans', back_populates='copy')
    reservations: Mapped[list['Reservations']] = relationship('Reservations', back_populates='fulfilled_by_copy')


class MaterialAuthors(Base):
    __tablename__ = 'material_authors'
    __table_args__ = (
        CheckConstraint("author_role IN \n        ('Primary Author', 'Co-Author', 'Contributor', 'Editor', 'Translator', 'Illustrator')", name='chk_author_role'),
        ForeignKeyConstraint(['author_id'], ['C##PROJET_DB.authors.author_id'], ondelete='CASCADE', name='fk_mat_auth_author'),
        ForeignKeyConstraint(['material_id'], ['C##PROJET_DB.materials.material_id'], ondelete='CASCADE', name='fk_mat_auth_material'),
        PrimaryKeyConstraint('material_id', 'author_id', name='pk_material_authors'),
        {'comment': 'Junction table linking materials to their authors (M:N '
                'relationship)',
     'schema': 'C##PROJET_DB'}
    )

    material_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    author_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    author_role: Mapped[Optional[str]] = mapped_column(VARCHAR(30), server_default=text("'Primary Author'"))
    author_sequence: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), server_default=text('1'))

    author: Mapped['Authors'] = relationship('Authors', back_populates='material_authors')
    material: Mapped['Materials'] = relationship('Materials', back_populates='material_authors')


class MaterialGenres(Base):
    __tablename__ = 'material_genres'
    __table_args__ = (
        ForeignKeyConstraint(['genre_id'], ['C##PROJET_DB.genres.genre_id'], ondelete='CASCADE', name='fk_mat_gen_genre'),
        ForeignKeyConstraint(['material_id'], ['C##PROJET_DB.materials.material_id'], ondelete='CASCADE', name='fk_mat_gen_material'),
        PrimaryKeyConstraint('material_id', 'genre_id', name='pk_material_genres'),
        {'comment': 'Junction table linking materials to genres (M:N relationship)',
     'schema': 'C##PROJET_DB'}
    )

    material_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    genre_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    is_primary_genre: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'N'"))

    genre: Mapped['Genres'] = relationship('Genres', back_populates='material_genres')
    material: Mapped['Materials'] = relationship('Materials', back_populates='material_genres')


class Patrons(Base):
    __tablename__ = 'patrons'
    __table_args__ = (
        CheckConstraint("account_status IN \n        ('Active', 'Expired', 'Suspended', 'Blocked')", name='chk_account_status'),
        CheckConstraint('max_borrow_limit > 0', name='chk_borrow_limit'),
        CheckConstraint("membership_type IN \n        ('Visitor /Guest', 'Standard', 'Adult', 'VIP', 'Premium', 'Child', 'Senior', 'Student', 'Staff')", name='chk_membership_type'),
        CheckConstraint('total_fines_owed >= 0', name='chk_fines_positive'),
        ForeignKeyConstraint(['registered_branch_id'], ['C##PROJET_DB.branches.branch_id'], name='fk_patron_branch'),
        ForeignKeyConstraint(['user_id'], ['C##PROJET_DB.users.user_id'], ondelete='SET NULL', name='fk_patron_user'),
        PrimaryKeyConstraint('patron_id', name='sys_c0011445'),
        Index('sys_c0011446', 'card_number', unique=True),
        Index('sys_c0011447', 'email', unique=True),
        Index('uq_patron_user', 'user_id', unique=True),
        {'comment': 'Registered library patrons (members or visitors) who can borrow '
                'or access library resources.',
     'schema': 'C##PROJET_DB'}
    )

    patron_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Unique identifier for each patron; serves as the primary key.')
    card_number: Mapped[str] = mapped_column(VARCHAR(20), nullable=False, comment='Unique library card number or barcode assigned to the patron.')
    first_name: Mapped[str] = mapped_column(VARCHAR(50), nullable=False, comment="Patron's given name (required).")
    last_name: Mapped[str] = mapped_column(VARCHAR(50), nullable=False, comment="Patron's family name (required).")
    registration_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '), comment='Date when the patron registered in the library system.')
    membership_expiry: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, comment="Date when the patron's membership privileges expire.")
    registered_branch_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False, comment="Foreign key linking to BRANCHES table indicating the patron's registration branch.")
    user_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), comment='Foreign key linking patron to USERS table - enables patrons to log in and access online services like catalog browsing, reservation management, and fine payment. NULL if patron has no online account (walk-in only).')
    email: Mapped[Optional[str]] = mapped_column(VARCHAR(100), comment='Unique email address used for account recovery and notifications.')
    phone: Mapped[Optional[str]] = mapped_column(VARCHAR(20), comment='Optional contact phone number.')
    address: Mapped[Optional[str]] = mapped_column(VARCHAR(200), comment='Residential or mailing address of the patron.')
    date_of_birth: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime, comment='Date of birth of the patron; used for age-specific plans or eligibility.')
    membership_type: Mapped[Optional[str]] = mapped_column(VARCHAR(20), server_default=text("'Standard'"), comment='Membership category (e.g., Visitor/Guest, Standard, Student, VIP, etc.).')
    account_status: Mapped[Optional[str]] = mapped_column(VARCHAR(20), server_default=text("'Active'"), comment='Current state of the account: Active, Expired, Suspended, or Blocked.')
    total_fines_owed: Mapped[Optional[decimal.Decimal]] = mapped_column(NUMBER(10, 2, True), server_default=text('0'), comment='Total amount of unpaid fines or fees owed by the patron.')
    max_borrow_limit: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), server_default=text('10'), comment='Maximum number of books or materials a patron can borrow simultaneously.')

    registered_branch: Mapped['Branches'] = relationship('Branches', back_populates='patrons')
    user: Mapped[Optional['Users']] = relationship('Users', back_populates='patrons')
    loans: Mapped[list['Loans']] = relationship('Loans', back_populates='patron')
    reservations: Mapped[list['Reservations']] = relationship('Reservations', back_populates='patron')
    fines: Mapped[list['Fines']] = relationship('Fines', back_populates='patron')


class Staff(Base):
    __tablename__ = 'staff'
    __table_args__ = (
        CheckConstraint('salary > 0', name='chk_salary_positive'),
        CheckConstraint("staff_role IN \n        ('Librarian', 'Assistant', 'Manager', 'Cataloger', 'IT Admin', 'Reception', 'Admin')", name='chk_staff_role'),
        ForeignKeyConstraint(['branch_id'], ['C##PROJET_DB.branches.branch_id'], name='fk_staff_branch'),
        ForeignKeyConstraint(['user_id'], ['C##PROJET_DB.users.user_id'], ondelete='SET NULL', name='fk_staff_user'),
        PrimaryKeyConstraint('staff_id', name='sys_c0011461'),
        Index('sys_c0011462', 'employee_number', unique=True),
        Index('sys_c0011463', 'email', unique=True),
        Index('uq_staff_user', 'user_id', unique=True),
        {'comment': 'Library employees who manage operations and services in each '
                'branch',
     'schema': 'C##PROJET_DB'}
    )

    staff_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True, comment='Primary key identifying each staff member')
    employee_number: Mapped[str] = mapped_column(VARCHAR(20), nullable=False, comment='Unique employee number for internal HR tracking')
    first_name: Mapped[str] = mapped_column(VARCHAR(50), nullable=False)
    last_name: Mapped[str] = mapped_column(VARCHAR(50), nullable=False)
    email: Mapped[str] = mapped_column(VARCHAR(100), nullable=False)
    staff_role: Mapped[str] = mapped_column(VARCHAR(30), nullable=False, comment='Role: Librarian, Assistant, Manager, Cataloger, IT Admin, etc.')
    branch_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False, comment='Branch where the staff member works')
    hire_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    user_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), comment='Foreign key linking staff to USERS table - enables staff to authenticate and access system functions based on their assigned roles (e.g., Librarian can check out books, Manager can generate reports). NULL if staff position does not require system access.')
    phone: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    salary: Mapped[Optional[decimal.Decimal]] = mapped_column(NUMBER(10, 2, True), comment='Monthly or annual salary, must be positive')
    is_active: Mapped[Optional[str]] = mapped_column(Enum('Y', 'N'), server_default=text("'Y'"), comment='Indicates if staff member is currently active (Y/N)')

    branch: Mapped['Branches'] = relationship('Branches', back_populates='staff')
    user: Mapped[Optional['Users']] = relationship('Users', back_populates='staff')
    loans: Mapped[list['Loans']] = relationship('Loans', foreign_keys='[Loans.staff_id_checkout]', back_populates='staff')
    loans_: Mapped[list['Loans']] = relationship('Loans', foreign_keys='[Loans.staff_id_return]', back_populates='staff_')
    fines: Mapped[list['Fines']] = relationship('Fines', foreign_keys='[Fines.assessed_by_staff_id]', back_populates='assessed_by_staff')
    fines_: Mapped[list['Fines']] = relationship('Fines', foreign_keys='[Fines.waived_by_staff_id]', back_populates='waived_by_staff')


class Loans(Base):
    __tablename__ = 'loans'
    __table_args__ = (
        CheckConstraint('due_date >= checkout_date', name='chk_dates_logical'),
        CheckConstraint('due_date >= checkout_date', name='chk_dates_logical'),
        CheckConstraint('renewal_count >= 0 AND renewal_count <= 5', name='chk_renewal_count'),
        CheckConstraint('return_date IS NULL OR return_date >= checkout_date', name='chk_return_logical'),
        CheckConstraint('return_date IS NULL OR return_date >= checkout_date', name='chk_return_logical'),
        ForeignKeyConstraint(['copy_id'], ['C##PROJET_DB.copies.copy_id'], name='fk_loan_copy'),
        ForeignKeyConstraint(['patron_id'], ['C##PROJET_DB.patrons.patron_id'], name='fk_loan_patron'),
        ForeignKeyConstraint(['staff_id_checkout'], ['C##PROJET_DB.staff.staff_id'], name='fk_loan_staff_checkout'),
        ForeignKeyConstraint(['staff_id_return'], ['C##PROJET_DB.staff.staff_id'], name='fk_loan_staff_return'),
        PrimaryKeyConstraint('loan_id', name='sys_c0011503'),
        {'comment': 'Records of material borrowing and return transactions',
     'schema': 'C##PROJET_DB'}
    )

    loan_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    patron_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    copy_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    checkout_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    due_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    staff_id_checkout: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    return_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    renewal_count: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), server_default=text('0'), comment='Number of renewals (max 5)')
    loan_status: Mapped[Optional[str]] = mapped_column(Enum('Active', 'Returned', 'Overdue', 'Lost'), server_default=text("'Active'"), comment='Active, Returned, Overdue, or Lost')
    staff_id_return: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))

    copy: Mapped['Copies'] = relationship('Copies', back_populates='loans')
    patron: Mapped['Patrons'] = relationship('Patrons', back_populates='loans')
    staff: Mapped['Staff'] = relationship('Staff', foreign_keys=[staff_id_checkout], back_populates='loans')
    staff_: Mapped[Optional['Staff']] = relationship('Staff', foreign_keys=[staff_id_return], back_populates='loans_')
    fines: Mapped[list['Fines']] = relationship('Fines', back_populates='loan')


class Reservations(Base):
    __tablename__ = 'reservations'
    __table_args__ = (
        CheckConstraint('queue_position > 0', name='chk_queue_position'),
        CheckConstraint("reservation_status IN \n        ('Pending', 'Ready', 'Fulfilled', 'Expired', 'Cancelled')", name='chk_reservation_status'),
        ForeignKeyConstraint(['fulfilled_by_copy_id'], ['C##PROJET_DB.copies.copy_id'], name='fk_reservation_copy'),
        ForeignKeyConstraint(['material_id'], ['C##PROJET_DB.materials.material_id'], name='fk_reservation_material'),
        ForeignKeyConstraint(['patron_id'], ['C##PROJET_DB.patrons.patron_id'], name='fk_reservation_patron'),
        PrimaryKeyConstraint('reservation_id', name='sys_c0011513'),
        {'comment': 'Manages patron reservations and hold queues for unavailable '
                'materials',
     'schema': 'C##PROJET_DB'}
    )

    reservation_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    material_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    patron_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    reservation_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    notification_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    pickup_deadline: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    reservation_status: Mapped[Optional[str]] = mapped_column(VARCHAR(20), server_default=text("'Pending'"), comment='Reservation progress (Pending, Ready, Fulfilled, etc.)')
    queue_position: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False), comment='Position of the patron in reservation queue')
    fulfilled_by_copy_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    notes: Mapped[Optional[str]] = mapped_column(VARCHAR(500))

    fulfilled_by_copy: Mapped[Optional['Copies']] = relationship('Copies', back_populates='reservations')
    material: Mapped['Materials'] = relationship('Materials', back_populates='reservations')
    patron: Mapped['Patrons'] = relationship('Patrons', back_populates='reservations')


class Fines(Base):
    __tablename__ = 'fines'
    __table_args__ = (
        CheckConstraint('amount_due >= 0 AND amount_paid >= 0 AND amount_paid <= amount_due', name='chk_fine_amounts'),
        CheckConstraint('amount_due >= 0 AND amount_paid >= 0 AND amount_paid <= amount_due', name='chk_fine_amounts'),
        CheckConstraint("fine_status IN \n        ('Unpaid', 'Partially Paid', 'Paid', 'Waived', 'Cancelled')", name='chk_fine_status'),
        CheckConstraint("fine_type IN \n        ('Overdue', 'Lost Item', 'Damaged Item', 'Processing Fee', 'Late Fee', 'Other')", name='chk_fine_type'),
        CheckConstraint("payment_method IS NULL OR payment_method IN \n        ('Cash', 'Credit Card', 'Debit Card', 'Check', 'Online', 'Waived')", name='chk_payment_method'),
        ForeignKeyConstraint(['assessed_by_staff_id'], ['C##PROJET_DB.staff.staff_id'], name='fk_fine_assessed_by'),
        ForeignKeyConstraint(['loan_id'], ['C##PROJET_DB.loans.loan_id'], name='fk_fine_loan'),
        ForeignKeyConstraint(['patron_id'], ['C##PROJET_DB.patrons.patron_id'], name='fk_fine_patron'),
        ForeignKeyConstraint(['waived_by_staff_id'], ['C##PROJET_DB.staff.staff_id'], name='fk_fine_waived_by'),
        PrimaryKeyConstraint('fine_id', name='sys_c0011525'),
        {'comment': 'Tracks fines and penalties for overdue or damaged materials',
     'schema': 'C##PROJET_DB'}
    )

    fine_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    patron_id: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    fine_type: Mapped[str] = mapped_column(VARCHAR(30), nullable=False, comment='Specifies reason for fine (Overdue, Lost Item, etc.)')
    amount_due: Mapped[decimal.Decimal] = mapped_column(NUMBER(10, 2, True), nullable=False, comment='Total fine assessed to patron')
    date_assessed: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False, server_default=text('SYSDATE '))
    loan_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    amount_paid: Mapped[Optional[decimal.Decimal]] = mapped_column(NUMBER(10, 2, True), server_default=text('0'), comment='Amount already paid by patron')
    payment_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    fine_status: Mapped[Optional[str]] = mapped_column(VARCHAR(20), server_default=text("'Unpaid'"), comment='Indicates payment status of fine (Paid, Unpaid, Waived, etc.)')
    assessed_by_staff_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    waived_by_staff_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    waiver_reason: Mapped[Optional[str]] = mapped_column(VARCHAR(500))
    payment_method: Mapped[Optional[str]] = mapped_column(VARCHAR(30), comment='Mode of payment used by patron')
    notes: Mapped[Optional[str]] = mapped_column(VARCHAR(500))

    assessed_by_staff: Mapped[Optional['Staff']] = relationship('Staff', foreign_keys=[assessed_by_staff_id], back_populates='fines')
    loan: Mapped[Optional['Loans']] = relationship('Loans', back_populates='fines')
    patron: Mapped['Patrons'] = relationship('Patrons', back_populates='fines')
    waived_by_staff: Mapped[Optional['Staff']] = relationship('Staff', foreign_keys=[waived_by_staff_id], back_populates='fines_')
