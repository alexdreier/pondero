#!/bin/bash

# Pondero Demo Quick Start Script
echo "🚀 Starting Pondero Demo Environment..."
echo "===================================="

# Check if Rails is available
if ! command -v rails &> /dev/null; then
    echo "❌ Rails not found. Please install Rails 8.0+ first:"
    echo "   gem install rails"
    exit 1
fi

# Check if PostgreSQL is running
if ! pg_isready &> /dev/null; then
    echo "⚠️  PostgreSQL is not running. Starting PostgreSQL..."
    
    # Try different ways to start PostgreSQL
    if command -v brew &> /dev/null; then
        brew services start postgresql
    elif command -v systemctl &> /dev/null; then
        sudo systemctl start postgresql
    elif command -v service &> /dev/null; then
        sudo service postgresql start
    else
        echo "❌ Could not start PostgreSQL automatically."
        echo "   Please start PostgreSQL manually and run this script again."
        exit 1
    fi
    
    sleep 3
fi

# Install dependencies
echo "📦 Installing dependencies..."
bundle install

# Setup database
echo "🗄️  Setting up database..."
rails db:create
rails db:migrate

# Load demo data
echo "📊 Loading demo data..."
rails db:seed

# Start server
echo "🌐 Starting Rails server..."
echo ""
echo "✅ Demo environment ready!"
echo ""
echo "🔗 Access the demo at: http://localhost:3000"
echo ""
echo "Demo Accounts:"
echo "Administrator: admin@pondero.demo / demo123456"
echo "Instructor: instructor@pondero.demo / demo123456"
echo "Learner: learner@pondero.demo / demo123456"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

rails server