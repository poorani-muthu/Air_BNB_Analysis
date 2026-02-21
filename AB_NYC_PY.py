import pandas as pd
import numpy as np
import sqlite3
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for .py files
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# 🔥 NEW CUSTOM COLOR PALETTE from your image
NEW_CUSTOM_PALETTE = ['#54CCCC', '#144F9B', '#74A0E4', '#DCC964', '#233502']

# Set style for beautiful plots with NEW colors
plt.style.use('default')
sns.set_palette(NEW_CUSTOM_PALETTE)
plt.rcParams['figure.facecolor'] = '#FAFAFA'
plt.rcParams['axes.facecolor'] = '#FFFFFF'
plt.rcParams['savefig.facecolor'] = '#FAFAFA'

print("🎨 NEW Color palette loaded!")
print("🌈 Colors: #54CCCC, #144F9B, #74A0E4, #DCC964, #233502")
print("🚀 Starting Airbnb NYC 2019 Analysis...")

# 1. LOAD DATASET
print("\n📊 Loading dataset...")
df = pd.read_csv('AB_NYC_2019.csv')
print(f"Original shape: {df.shape}")

# 2. CLEAN DATA
def clean_airbnb_data(df):
    df_clean = df.copy()
    
    print("\n🧹 Cleaning data...")
    print("Missing values before cleaning:")
    print(df_clean.isnull().sum())
    
    # Drop critical missing values
    df_clean = df_clean.dropna(subset=['name', 'host_name', 'neighbourhood', 'latitude', 'longitude', 'room_type'])
    df_clean['neighbourhood_group'].fillna('Other', inplace=True)
    
    # Handle dates and reviews
    df_clean['last_review'] = pd.to_datetime(df_clean['last_review'], errors='coerce')
    df_clean['has_reviews'] = df_clean['last_review'].notna()
    df_clean['reviews_per_month'] = df_clean['reviews_per_month'].fillna(0)
    
    # Remove outliers
    initial_count = len(df_clean)
    df_clean = df_clean[df_clean['price'] <= 1000]
    df_clean = df_clean[df_clean['minimum_nights'] <= 30]
    
    print(f"✅ Cleaned: {len(df_clean):,} rows ({initial_count - len(df_clean):,} removed)")
    return df_clean

df_clean = clean_airbnb_data(df)

# 3. CREATE DATABASE
print("\n🗄️ Creating SQL database...")
conn = sqlite3.connect('airbnb_nyc_cleaned.db')
df_clean.to_sql('airbnb_listings', conn, if_exists='replace', index=False)

# Add indexes
conn.execute('CREATE INDEX IF NOT EXISTS idx_neighborhood ON airbnb_listings(neighbourhood_group, neighbourhood)')
conn.execute('CREATE INDEX IF NOT EXISTS idx_price ON airbnb_listings(price)')
conn.execute('CREATE INDEX IF NOT EXISTS idx_room_type ON airbnb_listings(room_type)')
conn.close()
print("✅ Database saved: airbnb_nyc_cleaned.db")

# 4. MAIN DASHBOARD (9 Charts) - NEW COLORS!
print("\n📈 Creating main dashboard with NEW colors...")
fig, axes = plt.subplots(3, 3, figsize=(20, 16))
fig.patch.set_facecolor('#FAFAFA')
fig.suptitle('🏠 Airbnb NYC 2019 - Complete Analysis', fontsize=24, fontweight='bold', y=0.98)

# Chart 1: Price Distribution (Cyan #54CCCC)
axes[0,0].hist(df_clean['price'], bins=50, color=NEW_CUSTOM_PALETTE[0], alpha=0.85, edgecolor='white', linewidth=1.5)
axes[0,0].set_title('💰 Price Distribution', fontweight='bold', fontsize=14, pad=20)
axes[0,0].grid(True, alpha=0.3)

# Chart 2: Room Type Pie (Full NEW palette)
room_counts = df_clean['room_type'].value_counts()
axes[0,1].pie(room_counts.values, labels=room_counts.index, colors=NEW_CUSTOM_PALETTE, 
              autopct='%1.1f%%', startangle=90, textprops={'fontsize': 11, 'fontweight': 'bold'})
axes[0,1].set_title('🛏️ Room Types', fontweight='bold', fontsize=14, pad=20)

# Chart 3: Neighborhood Bar (NEW palette)
nbhd_dist = df_clean['neighbourhood_group'].value_counts()
bars = axes[0,2].bar(nbhd_dist.index, nbhd_dist.values, color=NEW_CUSTOM_PALETTE, alpha=0.9, edgecolor='white', linewidth=2)
axes[0,2].set_title('📍 Neighborhoods', fontweight='bold', fontsize=14, pad=20)
axes[0,2].tick_params(axis='x', rotation=45)
axes[0,2].grid(True, alpha=0.3, axis='y')

# Chart 4: Price by Room Type (NEW colors)
sns.boxplot(data=df_clean, x='room_type', y='price', ax=axes[1,0], palette=NEW_CUSTOM_PALETTE[:3])
axes[1,0].set_title('💵 Price by Room Type', fontweight='bold', fontsize=14, pad=20)
axes[1,0].tick_params(axis='x', rotation=45)

# Chart 5: Reviews vs Price
scatter = axes[1,1].scatter(df_clean['number_of_reviews'], df_clean['price'], 
                           c=df_clean['price'], cmap='Blues', alpha=0.6, s=25, edgecolors='white')
axes[1,1].set_xlabel('Reviews')
axes[1,1].set_ylabel('Price ($)')
axes[1,1].set_title('⭐ Reviews vs Price', fontweight='bold', fontsize=14, pad=20)
axes[1,1].grid(True, alpha=0.3)

# Chart 6: Availability (Dark Green #233502)
axes[1,2].hist(df_clean['availability_365'], bins=30, color=NEW_CUSTOM_PALETTE[4], alpha=0.85, edgecolor='white')
axes[1,2].set_title('📅 Availability', fontweight='bold', fontsize=14, pad=20)
axes[1,2].set_xlabel('Days Available')
axes[1,2].grid(True, alpha=0.3)

# Chart 7: Avg Price by Neighborhood (NEW palette)
price_by_nbhd = df_clean.groupby('neighbourhood_group')['price'].mean().sort_values(ascending=False)
bars7 = axes[2,0].bar(price_by_nbhd.index, price_by_nbhd.values, color=NEW_CUSTOM_PALETTE, alpha=0.9)
axes[2,0].set_title('🏙️ Avg Price by Area', fontweight='bold', fontsize=14, pad=20)
axes[2,0].tick_params(axis='x', rotation=45)
axes[2,0].grid(True, alpha=0.3, axis='y')

# Chart 8: Top 10 Neighborhoods (Reverse NEW palette)
top_neigh = df_clean.groupby('neighbourhood')['price'].mean().nlargest(10)
bars8 = axes[2,1].barh(range(len(top_neigh)), top_neigh.values, color=NEW_CUSTOM_PALETTE[::-1])
axes[2,1].set_yticks(range(len(top_neigh)))
axes[2,1].set_yticklabels(top_neigh.index)
axes[2,1].set_title('🔥 Top 10 Neighborhoods', fontweight='bold', fontsize=14, pad=20)
axes[2,1].grid(True, alpha=0.3, axis='x')

# Chart 9: Correlation Heatmap
numeric_cols = ['price', 'minimum_nights', 'number_of_reviews', 'reviews_per_month']
corr = df_clean[numeric_cols].corr()
sns.heatmap(corr, annot=True, cmap='RdYlGn', center=0, ax=axes[2,2], fmt='.2f')
axes[2,2].set_title('📊 Correlations', fontweight='bold', fontsize=14, pad=20)

plt.tight_layout()
plt.savefig('airbnb_dashboard.png', dpi=300, bbox_inches='tight', facecolor='#FAFAFA')
plt.close()  # Fixed: Don't show, just save
print("✅ Dashboard saved: airbnb_dashboard.png")

# 5. INSIGHTS
print("\n🏆 KEY INSIGHTS:")
print(f"• Total listings: {len(df_clean):,}")
print(f"• Avg price: ${df_clean['price'].mean():.0f}")
print(f"• Most popular room: {df_clean['room_type'].mode()[0]}")

neigh_summary = df_clean.groupby('neighbourhood_group')['price'].agg(['mean', 'count']).round(0)
print("\nNeighborhood Summary:")
print(neigh_summary)

print("\n✅ ANALYSIS COMPLETE!")
print("\n📁 FILES CREATED:")
print("   • airbnb_nyc_cleaned.db (SQL database)")
print("   • airbnb_dashboard.png (9-chart dashboard)")

