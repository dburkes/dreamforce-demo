
!SLIDE title main

# Building and deploying great apps with Salesforce, Heroku, and Ruby
![Pivotal](images/logo.png)
## Danny Burkes, Pivotal Labs
### danny@pivotallabs.com
### @dburkes

!SLIDE

# Introduction
* How did this happen?
* Pivotal who?
* Can I deploy to production later today?

!SLIDE huge

# YES

!SLIDE

# How did I get here?
* Heroku and Salesforce asked us to develop a gem
* It's open source
* You can start using it last week
* Pull requests gladly accepted

!SLIDE

# Why Ruby?
* Coding feedback cycle is immediate
* Huge open source community- use, don't write
* **Developer happiness matters**

!SLIDE

# Why Heroku?
* Show of hands- who &#x2665; running servers?
* Taking the "process" out of "deployment process"
* Rich set of add-ons to support the available Ruby gems
* **Developer happiness matters**

!SLIDE

# The databasedotcom Gem
* A Ruby wrapper for the Salesforce REST APIs
* Covers both the Sobject API and the Chatter API
* Full CRUD- no need to involve any UI unless you want to
* Full support for Salesforce-based OAuth, so your data is secure and access privileges are controlled by the database admin
* **Database admin happiness matters**

!SLIDE

# The Sobject API
* Full CRUD for a relational database
* Introspect classes and materialize local Ruby classes
* Use database.com/SFDC as a back-end to your web app, or
* Use your existing SFDC workflow to extract more value from your web app

!SLIDE

# The Chatter API
* Full CRUD for a social graph and UGC on top of Sobjects
* Post updates, make comments, like content, join groups
* Drive social activity and create conversations around newly-surfaced data from your existing SFDC instance
    
!SLIDE huge

# WARNING

!SLIDE huge

# CODE

!SLIDE

# Initializing the client
@@@ ruby

    # configure client id/secret explicitly
    #
    client = Databasedotcom::Client.new :client_id => "xxx", 
      :client_secret => "yyy"

    # configure client id/secret from a YAML file
    #
    client = Databasedotcom::Client.new "databasedotcom.yml"
    
    # configure client id/secret from the environment
    #
    client = Databasedotcom::Client.new 
    
@@@

!SLIDE

# Authentication
@@@ ruby

    # authenticate with a username and password
    #
    client.authenticate(:username => "wayne@manor.com", :password => "arkham")
    
    # authenticate with a callback hash from Omniauth
    #
    client.authenticate(hash_from_omniauth)
    
    # authenticate with an externally-acquired OAuth2 access token
    #
    client.authenticate(:token => "whoa-that-is-long")
@@@

!SLIDE

# The Sobject API
@@@ ruby

    sobject_classnames = client.list_sobjects   #=> ['Contact', 'Car', 'Company']
    
    client.materialize('Contact')
    
    Contact.create "Name" => "Ron Jenkins"
    
    pivots = Contact.find_all_by_Company("Pivotal Labs")
    
    ron = Contact.find_by_Id("whatever")
    ron.update_attributes "Company" => "Some New Gig, LLC"
    
    ron.delete

@@@

!SLIDE

# Materialized Class Attributes
@@@ ruby

    client.materialize("Contact")
    Contact.attributes               #=> ["Name", "Company", "Phone"]
    
    ron = Contact.find("rons_id")
    puts ron["Company"]             #=> "The Olde Company, Inc."

    ron["Company"] = "Some New Gig, LLC"
    ron.reload["Company"]           #=> "The Olde Company, Inc."
    
    ron["Company"] = "Some New Gig, LLC"
    ron.save
    ron.reload["Company"]           #=> "Some New Gig, LLC"

@@@

!SLIDE

# Form-building Attributes
@@@ ruby

    Contact.label_for("Phone")              #=> "Phone Number"
    Contact.picklist_values("Honorific")    #=> ["Mr.", "Ms.", "Dr."]

@@@
* Materialized class attributes are named for the field names, but you also have access to the labels
* Enumerated attributes also declare their possible values

!SLIDE

# Materialized Class Finder Methods

### Static Finders
@@@ ruby

    Contact.find('some-id')
    
    Contact.first("Company = 'Pivotal Labs'")

@@@

### Dynamic Finders
@@@ ruby

    Contact.find_by_Company_and_Title('Pivotal Labs', 'CEO')
    
    Contact.find_all_by_Company('Pivotal Labs')
@@@

!SLIDE

# Query and search

### Query uses SOQL
@@@ ruby

    Car.query("Color = 'Blue'")     #=> a Collection of Cars

@@@

### Search uses SOSL
@@@ ruby

    Account.search("FIND {bar}")    #=> a Colletion of Accounts

@@@

!SLIDE

# Collections
* Behaves like an Array, but also understands pagination
@@@ ruby

    cars = Car.all
    
    cars.length                 #=> 20
    cars.total_size             #=> 25
    cars.next_page?             #=> true
    
    more_cars = cars.next_page
    more_cars.length            #=> 5
    more_cars.total_size        #=> 25
    more_cars.next_page?        #=> false
    more_cars.previous_page?    #=> true

@@@

!SLIDE

# ActiveRecord Compatibility
* Syntax of attr_accessors, finders, create, update_attributes is very familiar for Rails programmers
* Sobjects are compatible with Rails' form_for view helpers
* This is not an ActiveRecord adapter

!SLIDE huge

# YET

!SLIDE

# The Chatter API
@@@ ruby

    feed_items = Databasedotcom::Chatter::CompanyFeed.find(client, "me")
    
    feed_items.each do |feed_item|
      feed_item.likes                   #=> a Collection of Likes
      feed_item.comments                #=> a Collection of Comments
      feed_item.raw_hash                #=> a hash describing this FeedItem
      feed_item.comment("This is cool") #=> create a new comment on the FeedItem
      feed_item.like                    #=> like the FeedItem
    end
    
    me = Databasedotcom::Chatter::User.find(client, "me")
    me.followers                                            #=> a Collection of Users
    me.post_status("what I'm doing now")                    #=> post a new status

    you = Databasedotcom::Chatter::User.find(client, "your-user-id")
    
    me.follow(you)                                          #=> start following a user

@@@

!SLIDE huge

# SNOOOZE

!SLIDE title

#### This is a highly-engaging presentation, but what can I build with this?

!SLIDE

# Rails and the RESTful resource idiom
* index, show, new, create, edit, update, delete
* resource routing
* a basic and familiar idiom for Rails developers

!SLIDE
# Let's do it with a databasedotcom backing
* Create a new Rails app
* Declare our gem dependencies and configure databasedotcom
* Create a new Heroku app
* Push our changes to Heroku
* OK, how to deploy this thing?

!SLIDE huge

# OMG I JUST DID

!SLIDE
# The Users Controller
* use the Rails generator
* include Databasedotcom::Rails::Controller
* fill in the actions as you normally do
* you're done

!SLIDE
# Form rendering
* Sobject.label_for
* Sobject.field_type
* Sobject.picklist_values

!SLIDE
# Parameter Coercion
* Parameter values are submitted as strings
* We must coerce them to the types expected by the Sobject API

!SLIDE

# Workflow possibilities with SFDC
* This is Salesforce, right?
* Use native workflow, and the SFDC ecosystem, to extract more value from data generated by your ruby/Rails frontend

!SLIDE

# Ummm, _WHY_ ?
* This was a simple example, granted
* The ability to use your Salesforce database in a Rails app means best-of-breed webapps + best-of-breed cloud databases
* Enterprises can embrace web development best practices without leaving their data behind
* User Experience expectations are driven by the web

!SLIDE

# Can I see that again?
* https://github.com/dburkes/dreamforce-demo
* http://dreamforce-demo.heroku.com
* http://dreamforce-demo.heroku.com/slides

!SLIDE huge

# THANK YOU
