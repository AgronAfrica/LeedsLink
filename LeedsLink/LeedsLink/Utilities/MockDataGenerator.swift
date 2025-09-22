import Foundation

struct MockDataGenerator {
    static func generateMockUsers() -> [User] {
        return [
            User(
                name: "Sarah Mitchell",
                businessName: "Sarah's Catering Co.",
                role: .serviceProvider,
                address: "12 Victoria Road, Headingley",
                phoneNumber: "0113 234 5678",
                postcode: "LS6 3AA",
                description: "Professional catering services for events and corporate functions"
            ),
            User(
                name: "James Thompson",
                businessName: "Thompson Plumbing Services",
                role: .serviceProvider,
                address: "45 Kirkstall Road, Kirkstall",
                phoneNumber: "0113 345 6789",
                postcode: "LS5 3AA",
                description: "Licensed plumber with 15 years experience in Leeds"
            ),
            User(
                name: "Emma Wilson",
                businessName: "Wilson's Organic Farm",
                role: .supplier,
                address: "Farm House, Meanwood Valley",
                phoneNumber: "0113 456 7890",
                postcode: "LS7 4JY",
                description: "Local organic produce supplier serving Leeds area"
            ),
            User(
                name: "David Chen",
                businessName: "Chen Digital Solutions",
                role: .serviceProvider,
                address: "78 Chapel Allerton Road, Chapel Allerton",
                phoneNumber: "0113 567 8901",
                postcode: "LS7 4PD",
                description: "Web design and digital marketing services for local businesses"
            ),
            User(
                name: "Lisa Brown",
                businessName: "Brown & Associates Accounting",
                role: .serviceProvider,
                address: "23 Roundhay Road, Roundhay",
                phoneNumber: "0113 678 9012",
                postcode: "LS8 1BA",
                description: "Chartered accountants specializing in small business services"
            ),
            User(
                name: "Michael O'Connor",
                businessName: "O'Connor Cleaning Services",
                role: .serviceProvider,
                address: "56 City Centre, Leeds",
                phoneNumber: "0113 789 0123",
                postcode: "LS2 8BU",
                description: "Commercial and residential cleaning services"
            ),
            User(
                name: "Rachel Green",
                businessName: "Green Design Studio",
                role: .serviceProvider,
                address: "89 Hyde Park Corner, Hyde Park",
                phoneNumber: "0113 890 1234",
                postcode: "LS6 1BJ",
                description: "Graphic design and branding specialist"
            ),
            User(
                name: "Tom Anderson",
                businessName: "Anderson Coffee Roasters",
                role: .supplier,
                address: "34 Moortown Lane, Moortown",
                phoneNumber: "0113 901 2345",
                postcode: "LS17 6NY",
                description: "Artisan coffee roaster supplying local cafes and restaurants"
            ),
            User(
                name: "Sophie Taylor",
                businessName: "Taylor Wellness",
                role: .serviceProvider,
                address: "67 Garforth High Street, Garforth",
                phoneNumber: "0113 012 3456",
                postcode: "LS25 1PR",
                description: "Certified yoga instructor and wellness coach"
            ),
            User(
                name: "Alex Johnson",
                businessName: "Johnson IT Solutions",
                role: .serviceProvider,
                address: "91 Horsforth Town Street, Horsforth",
                phoneNumber: "0113 123 4567",
                postcode: "LS18 5HD",
                description: "IT support and network solutions for businesses"
            )
        ]
    }
    
    static func generateMockListings() -> [Listing] {
        let mockUsers = generateMockUsers()
        
        return [
            // Urgent requests
            Listing(
                userId: mockUsers[0].id,
                title: "Urgent: Need Catering for Corporate Event",
                category: .food,
                tags: ["catering", "event", "corporate", "buffet"],
                budget: "£500-800",
                availability: "This Saturday",
                description: "Looking for a catering service for a corporate event with 50 guests. Need vegetarian and vegan options.",
                type: .request,
                isUrgent: true,
                address: "Leeds City Centre, LS1 5ES",
                postcode: "LS1 5ES"
            ),
            Listing(
                userId: mockUsers[1].id,
                title: "Emergency Plumbing Services Available",
                category: .construction,
                tags: ["plumbing", "emergency", "24/7", "repair"],
                price: "£80/hour",
                availability: "24/7 Emergency Service",
                description: "Licensed plumber available for emergency repairs. Fast response time in Leeds area.",
                type: .offer,
                isUrgent: true,
                address: "45 Kirkstall Road, Kirkstall",
                postcode: "LS5 3AA"
            ),
            
            // Regular offers
            Listing(
                userId: mockUsers[2].id,
                title: "Fresh Local Produce Delivery",
                category: .food,
                tags: ["organic", "local", "vegetables", "delivery"],
                price: "From £20",
                availability: "Weekly deliveries on Wednesdays",
                description: "Farm-fresh organic vegetables delivered to your door. Supporting local farmers.",
                type: .offer,
                address: "Farm House, Meanwood Valley",
                postcode: "LS7 4JY"
            ),
            Listing(
                userId: mockUsers[3].id,
                title: "Professional Web Design Services",
                category: .technology,
                tags: ["web design", "responsive", "SEO", "modern"],
                price: "£500-2000",
                availability: "Mon-Fri, 9am-6pm",
                description: "Creating modern, responsive websites for local businesses. SEO optimization included.",
                type: .offer,
                address: "78 Chapel Allerton Road, Chapel Allerton",
                postcode: "LS7 4PD"
            ),
            Listing(
                userId: mockUsers[4].id,
                title: "Accounting Services for Small Businesses",
                category: .professional,
                tags: ["accounting", "bookkeeping", "tax", "payroll"],
                price: "£150/month",
                availability: "Flexible hours",
                description: "Comprehensive accounting services tailored for small businesses in Leeds.",
                type: .offer,
                address: "23 Roundhay Road, Roundhay",
                postcode: "LS8 1BA"
            ),
            
            // Regular requests
            Listing(
                userId: mockUsers[5].id,
                title: "Looking for Office Cleaning Service",
                category: .professional,
                tags: ["cleaning", "office", "weekly", "commercial"],
                budget: "£200/month",
                availability: "Evenings preferred",
                description: "Need reliable cleaning service for small office space. Weekly cleaning required.",
                type: .request,
                address: "56 City Centre, Leeds",
                postcode: "LS2 8BU"
            ),
            Listing(
                userId: mockUsers[6].id,
                title: "Need Logo Design for New Restaurant",
                category: .technology,
                tags: ["logo", "design", "branding", "restaurant"],
                budget: "£300-500",
                availability: "ASAP",
                description: "Opening a new restaurant in Leeds city center. Need professional logo and basic branding.",
                type: .request,
                address: "89 Hyde Park Corner, Hyde Park",
                postcode: "LS6 1BJ"
            ),
            Listing(
                userId: mockUsers[7].id,
                title: "Wholesale Coffee Supplier Needed",
                category: .food,
                tags: ["coffee", "wholesale", "beans", "supplier"],
                budget: "Negotiable",
                availability: "Regular supply",
                description: "Café looking for reliable coffee bean supplier. Need variety of blends and fair trade options.",
                type: .request,
                address: "34 Moortown Lane, Moortown",
                postcode: "LS17 6NY"
            ),
            Listing(
                userId: mockUsers[8].id,
                title: "Yoga Classes for Corporate Wellness",
                category: .health,
                tags: ["yoga", "wellness", "corporate", "fitness"],
                price: "£60/session",
                availability: "Flexible scheduling",
                description: "Certified yoga instructor offering corporate wellness sessions. Can accommodate groups up to 20.",
                type: .offer,
                address: "67 Garforth High Street, Garforth",
                postcode: "LS25 1PR"
            ),
            Listing(
                userId: mockUsers[9].id,
                title: "IT Support and Maintenance",
                category: .technology,
                tags: ["IT support", "maintenance", "network", "security"],
                price: "£50/hour",
                availability: "Mon-Sat, 8am-8pm",
                description: "Comprehensive IT support for small and medium businesses. Remote and on-site support available.",
                type: .offer,
                address: "91 Horsforth Town Street, Horsforth",
                postcode: "LS18 5HD"
            ),
            
            // Additional Leeds locations
            Listing(
                userId: mockUsers[0].id,
                title: "Wedding Catering Services",
                category: .food,
                tags: ["wedding", "catering", "events", "special occasions"],
                price: "From £25 per person",
                availability: "Weekends and special events",
                description: "Elegant wedding catering with customizable menus. Serving Leeds and surrounding areas.",
                type: .offer,
                address: "12 Victoria Road, Headingley",
                postcode: "LS6 3AA"
            ),
            Listing(
                userId: mockUsers[1].id,
                title: "Bathroom Renovation Services",
                category: .construction,
                tags: ["bathroom", "renovation", "tiling", "plumbing"],
                price: "£2000-8000",
                availability: "Mon-Fri, 8am-5pm",
                description: "Complete bathroom renovations including plumbing, tiling, and fixtures. Free quotes available.",
                type: .offer,
                address: "45 Kirkstall Road, Kirkstall",
                postcode: "LS5 3AA"
            ),
            Listing(
                userId: mockUsers[2].id,
                title: "Seasonal Vegetable Boxes",
                category: .food,
                tags: ["seasonal", "vegetables", "subscription", "organic"],
                price: "£15-25 per box",
                availability: "Weekly deliveries",
                description: "Seasonal vegetable subscription boxes delivered fresh from our Leeds farm. Support local agriculture.",
                type: .offer,
                address: "Farm House, Meanwood Valley",
                postcode: "LS7 4JY"
            ),
            Listing(
                userId: mockUsers[3].id,
                title: "E-commerce Website Development",
                category: .technology,
                tags: ["e-commerce", "online store", "payment", "mobile"],
                price: "£1000-5000",
                availability: "Project-based",
                description: "Complete e-commerce solutions for Leeds businesses. Payment integration and mobile optimization included.",
                type: .offer,
                address: "78 Chapel Allerton Road, Chapel Allerton",
                postcode: "LS7 4PD"
            ),
            Listing(
                userId: mockUsers[4].id,
                title: "Tax Return Services",
                category: .professional,
                tags: ["tax return", "self-employed", "deadline", "HMRC"],
                price: "£150-300",
                availability: "Tax season priority",
                description: "Professional tax return services for self-employed individuals and small businesses in Leeds.",
                type: .offer,
                address: "23 Roundhay Road, Roundhay",
                postcode: "LS8 1BA"
            ),
            
            // New listings for hospitality, education, transport, and other categories
            Listing(
                userId: mockUsers[0].id,
                title: "Boutique Hotel Accommodation",
                category: .hospitality,
                tags: ["hotel", "accommodation", "boutique", "city centre"],
                price: "£120-200/night",
                availability: "Year-round availability",
                description: "Luxurious boutique hotel in Leeds city centre. Perfect for business travelers and tourists. Modern amenities and excellent service.",
                type: .offer,
                address: "15 The Headrow, Leeds City Centre",
                postcode: "LS1 8TL"
            ),
            Listing(
                userId: mockUsers[1].id,
                title: "Need Hotel for Conference Attendees",
                category: .hospitality,
                tags: ["hotel", "conference", "group booking", "corporate"],
                budget: "£100-150 per room",
                availability: "March 15-17, 2024",
                description: "Looking for hotel accommodation for 20 conference attendees. Need group booking with corporate rates. Close to Leeds Arena preferred.",
                type: .request,
                isUrgent: false,
                address: "Leeds Arena area",
                postcode: "LS2 8BY"
            ),
            Listing(
                userId: mockUsers[2].id,
                title: "Private Tutoring Services",
                category: .education,
                tags: ["tutoring", "private lessons", "academic support", "GCSE"],
                price: "£35-50/hour",
                availability: "Evenings and weekends",
                description: "Qualified teacher offering private tutoring in Maths, English, and Science. Specializing in GCSE preparation. Home visits available.",
                type: .offer,
                address: "Various locations across Leeds",
                postcode: "LS1-LS20"
            ),
            Listing(
                userId: mockUsers[3].id,
                title: "Need Music Lessons for Child",
                category: .education,
                tags: ["music lessons", "piano", "child", "beginner"],
                budget: "£25-40 per lesson",
                availability: "Weekday afternoons",
                description: "Looking for piano lessons for my 8-year-old daughter. Prefer experienced teacher with child-friendly approach. Home visits preferred.",
                type: .request,
                isUrgent: false,
                address: "Chapel Allerton area",
                postcode: "LS7 4PD"
            ),
            Listing(
                userId: mockUsers[4].id,
                title: "Reliable Taxi Service",
                category: .transport,
                tags: ["taxi", "airport transfers", "city transport", "reliable"],
                price: "From £15",
                availability: "24/7 service",
                description: "Professional taxi service covering Leeds and surrounding areas. Airport transfers, city transport, and special events. Clean, comfortable vehicles.",
                type: .offer,
                address: "Leeds and surrounding areas",
                postcode: "LS1-LS20"
            ),
            Listing(
                userId: mockUsers[5].id,
                title: "Need Moving Services",
                category: .transport,
                tags: ["moving", "removal", "furniture", "house move"],
                budget: "£200-400",
                availability: "Weekend preferred",
                description: "Moving from Headingley to Roundhay. Need help with furniture and boxes. Two-bedroom flat contents. Looking for reliable and careful movers.",
                type: .request,
                isUrgent: false,
                address: "Headingley to Roundhay",
                postcode: "LS6 3AA to LS8 1BA"
            ),
            Listing(
                userId: mockUsers[6].id,
                title: "Event Photography Services",
                category: .other,
                tags: ["photography", "events", "weddings", "corporate"],
                price: "£200-800",
                availability: "Flexible scheduling",
                description: "Professional event photographer specializing in weddings, corporate events, and special occasions. High-quality images with quick turnaround.",
                type: .offer,
                address: "Leeds and surrounding areas",
                postcode: "LS1-LS20"
            ),
            Listing(
                userId: mockUsers[7].id,
                title: "Need Pet Grooming Services",
                category: .other,
                tags: ["pet grooming", "dog", "cat", "mobile service"],
                budget: "£30-60",
                availability: "Weekday mornings",
                description: "Looking for mobile pet grooming service for my two dogs. One is nervous around other animals, so home service preferred. Regular monthly appointments.",
                type: .request,
                isUrgent: false,
                address: "Meanwood area",
                postcode: "LS7 4JY"
            )
        ]
    }
    
    static func generateMockConversations(currentUserId: UUID?) -> [Conversation] {
        let mockUsers = generateMockUsers()
        let otherUsers = [
            (id: mockUsers[0].id, name: "Sarah's Catering Co."),
            (id: mockUsers[3].id, name: "Chen Digital Solutions"),
            (id: mockUsers[2].id, name: "Wilson's Organic Farm")
        ]
        
        var conversations: [Conversation] = []
        
        // Only create conversations if there's a current user
        guard let currentUserId = currentUserId else { return [] }
        
        // Conversation 1
        let conv1 = Conversation(
            participantIds: [currentUserId, otherUsers[0].id],
            participantNames: ["You", otherUsers[0].name],
            messages: [
                Message(
                    senderId: otherUsers[0].id,
                    senderName: otherUsers[0].name,
                    content: "Hi! I saw your request for catering services. We can definitely help with your corporate event.",
                    timestamp: Date().addingTimeInterval(-3600)
                ),
                Message(
                    senderId: currentUserId,
                    senderName: "You",
                    content: "Great! Can you accommodate 50 guests with vegetarian and vegan options?",
                    timestamp: Date().addingTimeInterval(-3000)
                ),
                Message(
                    senderId: otherUsers[0].id,
                    senderName: otherUsers[0].name,
                    content: "Absolutely! We have a diverse menu with plenty of vegetarian and vegan choices. Would you like to see our menu options?",
                    timestamp: Date().addingTimeInterval(-2400)
                )
            ]
        )
        conversations.append(conv1)
        
        // Conversation 2
        let conv2 = Conversation(
            participantIds: [currentUserId, otherUsers[1].id],
            participantNames: ["You", otherUsers[1].name],
            messages: [
                Message(
                    senderId: currentUserId,
                    senderName: "You",
                    content: "Hi, I'm interested in your web design services. What's included in your packages?",
                    timestamp: Date().addingTimeInterval(-7200)
                ),
                Message(
                    senderId: otherUsers[1].id,
                    senderName: otherUsers[1].name,
                    content: "Hello! Our packages include responsive design, SEO optimization, and 3 months of free maintenance. We also provide hosting setup if needed.",
                    timestamp: Date().addingTimeInterval(-6000)
                )
            ]
        )
        conversations.append(conv2)
        
        return conversations
    }
}
