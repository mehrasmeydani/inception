# USER_DOC.md - User Documentation

This document is for end users and administrators who want to understand and manage the Inception stack without needing to modify the code.

---

## Services Provided by the Stack

The Inception project provides a complete web hosting solution consisting of three integrated services:

### 1. **Nginx Web Server**
- **Purpose**: Acts as a reverse proxy and web server
- **Port**: Listens on ports 80 (HTTP) and 443 (HTTPS)
- **Function**: Routes incoming web traffic to the WordPress application
- **Security**: Handles SSL/TLS encryption for secure connections

### 2. **WordPress Content Management System (CMS)**
- **Purpose**: Allows content creation, editing, and management through a web interface
- **Access**: Available via the domain name (e.g., `megardes.42.fr`)
- **Function**: Provides the website frontend and admin dashboard
- **Capabilities**: Create posts, pages, manage users, customize themes and plugins

### 3. **MariaDB Database**
- **Purpose**: Stores all data (posts, pages, users, settings, etc.)
- **Access**: Internal only (not directly accessible from outside)
- **Function**: Maintains data persistence between container restarts
- **Security**: Does not expose port externally; only accessible within the Docker network

---

## Starting and Stopping the Project

### Prerequisites
- Docker and Docker Compose installed on your system
- Linux/macOS system or WSL2 on Windows
- Internet connection for initial setup

### Starting the Project

**Method 1: Using Make (Recommended)**
```bash
cd /home/megardes/inception
make
```

This command will:
1. Add the domain entry to `/etc/hosts` (may require password)
2. Build Docker images (first run only)
3. Start all three services (Nginx, WordPress, MariaDB)

**Expected output**: You'll see messages indicating services are initializing. Wait 1-2 minutes for full startup.

**See all Make commands**:
```bash
make help
```

### Accessing the Services

Once running, you can access:
- **Website**: Open your browser and navigate to `https://megardes.42.fr`
- **WordPress Admin**: Go to `https://megardes.42.fr/wp-admin`

Note: You may see a browser warning about SSL certificate (self-signed). This is expected; click "Advanced" and proceed.

### Stopping the Project

**Method 1: Using Make (Recommended)**
```bash
make clean
```

This stops all containers and networks but preserves data.

**Method 2: Full Cleanup**
```bash
make good_clean
```

This stops containers AND removes database/WordPress data. Use this to reset everything.

**Method 3: Complete Purge (WARNING: Destructive)**
```bash
make purge
```

This removes ALL Docker containers, images, volumes, and networks. Use only if you want a complete reset.

---

## Accessing the Website and Administration Panel

### Website Access

1. **Open your browser**
2. **Navigate to**: `https://megardes.42.fr`
3. **Accept the SSL warning** (self-signed certificate is expected in development)
4. You'll see the WordPress homepage

### WordPress Administration Panel

1. **Navigate to**: `https://megardes.42.fr/wp-admin`
2. **Login credentials**: 
   - Username: See "Locating and Managing Credentials" section below
   - Password: See "Locating and Managing Credentials" section below
3. **Administrator Dashboard Features**:
   - **Posts**: Create, edit, and delete blog posts
   - **Pages**: Manage static pages
   - **Media**: Upload and manage images, videos, files
   - **Users**: Add, edit, or remove user accounts
   - **Appearance**: Change themes and customize design
   - **Plugins**: Install and activate WordPress extensions
   - **Settings**: Configure site title, timezone, permalink structure, etc.
   - **Tools**: Website utilities and maintenance

### Common Administration Tasks

- **Publish Content**: Posts → Add New → Write content → Publish
- **Create Pages**: Pages → Add New → Write content → Publish
- **Change Theme**: Appearance → Themes → Select theme → Activate
- **Manage Users**: Users → Add New → Fill details → Add User
- **Update Plugins**: Plugins → Available Plugins → Click Install → Activate

---

## Locating and Managing Credentials

### Where Credentials Are Stored

Credentials are typically managed through environment variables in a `.env` file located in the `srcs/` directory:

```bash
cat /home/megardes/inception/srcs/.env
```

### Key Credentials in the Stack

| Credential | Default | Purpose | Where Used |
|------------|---------|---------|-----------|
| **WordPress Admin Username** | `admin` | WordPress login | `https://megardes.42.fr/wp-admin` |
| **WordPress Admin Password** | Check `.env` | WordPress login | `https://megardes.42.fr/wp-admin` |
| **WordPress Database User** | `wordpress` | Database access for WordPress | Internal (MariaDB container) |
| **WordPress Database Password** | Check `.env` | Database authentication | Internal (MariaDB container) |
| **MariaDB Root Password** | Check `.env` | Database administration | Internal (MariaDB container) |
| **Domain Name** | `megardes.42.fr` | Website address | Browser access |

### Viewing Credentials

To see the actual values:

```bash
# View the .env file
cat /home/megardes/inception/srcs/.env

# Or use grep to find specific values
grep -i "PASS\|USER" /home/megardes/inception/srcs/.env
```

### Changing Credentials

**WARNING**: Changing credentials requires rebuilding containers with new `.env` values.

1. **Edit the `.env` file**:
   ```bash
   nano /home/megardes/inception/srcs/.env
   # Edit and save
   ```

2. **Rebuild and restart**:
   ```bash
   cd /home/megardes/inception
   make good_clean    # Full cleanup
   make              # Rebuild with new credentials
   ```

3. **Important**: After changing WordPress credentials, you'll need to:
   - Log in with the new username/password at `https://megardes.42.fr/wp-admin`
   - Update any saved credentials in your browser's password manager

### Security Best Practices

- **Never commit `.env` to version control** (it's usually in `.gitignore`)
- **Use strong passwords**: Mix uppercase, lowercase, numbers, and special characters
- **Rotate credentials periodically** in production environments
- **Limit access**: Only share credentials with authorized users
- **Use HTTPS**: Always access the admin panel over HTTPS (never plain HTTP)

---

## Checking That Services Are Running Correctly

### Quick Health Check

**Using Docker Commands** (requires Docker knowledge):

```bash
# Check running containers
docker ps

# You should see three running containers:
# - inception-nginx-1
# - inception-wordpress-1
# - inception-mariadb-1

# View logs for a specific service
docker-compose -f /home/megardes/inception/srcs/docker-compose.yml logs -f nginx
```

### Website Accessibility Test

1. **Open browser**: Navigate to `https://megardes.42.fr`
2. **Expected result**: WordPress homepage loads without errors
3. **If it fails**: Wait 30-60 seconds and refresh; services may still be initializing

### Administration Panel Test

1. **Navigate to**: `https://megardes.42.fr/wp-admin`
2. **Expected result**: WordPress login page appears
3. **Login with credentials**: Use correct username and password
4. **Expected result**: WordPress dashboard displays

### Service Status Check

Check if each service is responding:

```bash
# Check Nginx (web server)
curl -k https://megardes.42.fr 2>/dev/null | head -20

# Check WordPress is running
curl -k https://megardes.42.fr/wp-admin 2>/dev/null | grep -q "wp-login" && echo "WordPress is running"

# Check MariaDB (indirectly through WordPress database connection)
curl -k https://megardes.42.fr/wp-json/wp/v2/posts 2>/dev/null | grep -q "post" && echo "Database is running"
```

### Common Issues and Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Services not starting** | Website times out or connection refused | Wait 2 minutes; services need time to initialize |
| **SSL certificate warning** | "Not secure" warning in browser | Expected for development; click "Advanced" and proceed |
| **Cannot login** | Login fails or redirects loop | Check credentials in `.env` file; ensure cookies are enabled |
| **Database connection error** | WordPress shows database error | Services may be restarting; wait and refresh |
| **Domain not resolving** | Cannot reach `megardes.42.fr` | Check `/etc/hosts` contains entry; may need admin restart |

### View Service Logs

To troubleshoot issues, check the service logs:

```bash
# View all service logs
docker-compose -f /home/megardes/inception/srcs/docker-compose.yml logs

# View specific service logs
docker-compose -f /home/megardes/inception/srcs/docker-compose.yml logs nginx
docker-compose -f /home/megardes/inception/srcs/docker-compose.yml logs wordpress
docker-compose -f /home/megardes/inception/srcs/docker-compose.yml logs mariadb

# Follow logs in real-time
docker-compose -f /home/megardes/inception/srcs/docker-compose.yml logs -f
```

### Performance Check

If the website is slow:

1. **Check available resources**:
   ```bash
   df -h              # Disk space
   free -h            # Memory available
   top                # CPU and memory usage
   ```

2. **Restart services** if needed:
   ```bash
   make clean
   make
   ```

3. **Check container resource usage**:
   ```bash
   docker stats
   ```

---

## Maintenance and Best Practices

### Regular Backups

To backup WordPress and database data:

```bash
# Backup WordPress files
tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz /home/megardes/data/wordpress/

# Backup database
docker-compose -f /home/megardes/inception/srcs/docker-compose.yml exec mariadb \
  mysqldump -u wordpress -p[password] wordpress > wordpress-db-backup-$(date +%Y%m%d).sql
```

### Cleaning Up

To free up disk space:

```bash
# Remove stopped containers and unused images
make fclean

# Or specifically remove dangling images
docker image prune -f
```

### Troubleshooting Resources

- **Docker Issues**: https://docs.docker.com/config/containers/logging/
- **WordPress Issues**: https://wordpress.org/support/
- **Nginx Issues**: https://nginx.org/en/docs/
- **MariaDB Issues**: https://mariadb.com/docs/

---

## Quick Reference

| Task | Command |
|------|---------|
| Start project | `make` |
| Stop project (keep data) | `make clean` |
| Stop and erase data | `make good_clean` |
| Complete reset (remove all Docker resources) | `make purge` |
| Restart services | `make clean && make` |
| Access website | `https://megardes.42.fr` |
| Access admin panel | `https://megardes.42.fr/wp-admin` |
| View logs | `docker-compose -f srcs/docker-compose.yml logs` |
| Check running services | `docker ps` |

---

## Support and Questions

If you encounter issues not covered in this documentation:

1. **Check the logs** for specific error messages
2. **Review the README.md** for architectural information
3. **Consult DEV_DOC.md** if you need developer-level information
4. **Contact the project maintainer** with specific error messages and logs
