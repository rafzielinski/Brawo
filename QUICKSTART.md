# Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Setup (First Time Only)

**On Mac/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

**On Windows:**
```cmd
setup.bat
```

**Or manually:**
```bash
docker-compose build
docker-compose up -d
docker-compose exec web bash -c "cd test/dummy && rails db:create db:migrate"
```

### Step 2: Access the Application

Open your browser:
- **Main Site**: http://localhost:3000
- **Admin Panel**: http://localhost:3000/admin

### Step 3: Create Content

1. Go to http://localhost:3000/admin
2. Click on "Articles" or "Products" in the sidebar
3. Click "New Article" or "New Product"
4. Fill in the form and click "Create"

## 📝 Create Sample Data (Optional)

```bash
docker-compose exec web bash
cd test/dummy
rails console
```

Then paste this Ruby code:

```ruby
# Create sample articles
Article.create!(
  title: "Getting Started with BrawoCMS",
  description: "Learn how to build powerful content management systems",
  status: "published",
  author: "John Doe",
  body: "This is a comprehensive guide to getting started with BrawoCMS. The engine provides a flexible way to manage different types of content in your Rails application.",
  published_date: Date.today.to_s,
  category: "tech",
  featured: true
)

Article.create!(
  title: "10 Tips for Better Content Management",
  description: "Expert tips for organizing your content effectively",
  status: "published",
  author: "Jane Smith",
  body: "Managing content effectively is crucial for any website. Here are 10 tips to help you organize your content better...",
  published_date: (Date.today - 7).to_s,
  category: "business",
  featured: false
)

# Create sample products
Product.create!(
  title: "Premium Subscription",
  description: "Access all premium features for your business",
  status: "published",
  price: 29.99,
  sku: "PREM-001",
  stock_quantity: 100,
  product_description: "Get unlimited access to all premium features including advanced analytics, priority support, and custom integrations.",
  availability: "in_stock",
  featured_product: true
)

Product.create!(
  title: "Starter Package",
  description: "Perfect for small projects and testing",
  status: "published",
  price: 9.99,
  sku: "START-001",
  stock_quantity: 50,
  product_description: "Start your journey with our basic package that includes all essential features you need to get started.",
  availability: "in_stock",
  featured_product: false
)

puts "✅ Created #{Article.count} articles and #{Product.count} products!"
```

## 🎯 What Can You Do?

### In the Admin Panel (http://localhost:3000/admin):
- ✏️ Create, edit, delete articles and products
- 📊 Manage content status (draft, published, archived)
- 🔍 View all your content in organized lists
- 🎨 Use dynamic forms that match your content type definitions

### On the Main Site (http://localhost:3000):
- 📰 Browse articles
- 🛍️ Browse products
- 👀 See how content is displayed to end users

## 📚 Learn More

### Create Your Own Content Type

Generate a new content type:
```bash
docker-compose exec web bash
cd test/dummy
rails generate brawo_cms:content_type Event name:string location:string event_date:date
```

Or create manually in `app/models/event.rb`:
```ruby
class Event < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :event,
    label: 'Event',
    fields: [
      { name: :name, type: :string, label: 'Event Name' },
      { name: :location, type: :string, label: 'Location' },
      { name: :event_date, type: :date, label: 'Event Date' }
    ]
end
```

### View Logs
```bash
docker-compose logs -f web
```

### Stop the Application
```bash
docker-compose down
```

### Restart the Application
```bash
docker-compose up -d
```

## 🆘 Need Help?

- Check `README.md` for detailed documentation
- See `DEVELOPMENT.md` for advanced usage
- See `DOCKER_SETUP.md` for Docker-specific help

## 🎉 Next Steps

1. Explore the admin interface
2. Create some content
3. View your content on the main site
4. Try creating your own content type
5. Customize the views and styling
6. Build your application!

Happy coding! 🚀

