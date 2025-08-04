import { prisma } from '@/lib/prisma';
import {
  CustomerField,
  CustomersTable,
  InvoiceForm,
  InvoicesTable,
  LatestInvoiceRaw,
  Revenue,
} from './definitions';

export async function fetchRevenue() {
  try {
    // Artificial delay of 3 seconds for demo purposes.
    console.log('Fetching revenue data...');
    await new Promise((resolve) => setTimeout(resolve, 3000));

    // Mock data for now
    const data: Revenue[] = [
      { month: 'Jan', revenue: 2000 },
      { month: 'Feb', revenue: 1800 },
      { month: 'Mar', revenue: 2200 },
      { month: 'Apr', revenue: 2500 },
      { month: 'May', revenue: 2300 },
      { month: 'Jun', revenue: 3200 },
      { month: 'Jul', revenue: 3500 },
      { month: 'Aug', revenue: 3700 },
      { month: 'Sep', revenue: 2500 },
      { month: 'Oct', revenue: 2800 },
      { month: 'Nov', revenue: 3000 },
      { month: 'Dec', revenue: 4800 },
    ];

    console.log('Data fetch completed after 3 seconds.');

    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch revenue data.');
  }
}

export async function fetchLatestInvoices() {
  try {
    // Mock data for now
    const data: LatestInvoiceRaw[] = [
      {
        id: '1',
        name: 'John Doe',
        image_url: '/customers/john-doe.png',
        email: 'john@example.com',
        amount: 15795,
      },
      {
        id: '2', 
        name: 'Jane Smith',
        image_url: '/customers/jane-smith.png',
        email: 'jane@example.com',
        amount: 20348,
      },
      {
        id: '3',
        name: 'Bob Johnson',
        image_url: '/customers/bob-johnson.png', 
        email: 'bob@example.com',
        amount: 3040,
      },
      {
        id: '4',
        name: 'Alice Wilson',
        image_url: '/customers/alice-wilson.png',
        email: 'alice@example.com',
        amount: 44800,
      },
      {
        id: '5',
        name: 'Charlie Brown',
        image_url: '/customers/charlie-brown.png',
        email: 'charlie@example.com',
        amount: 34577,
      },
    ];

    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch the latest invoices.');
  }
}

export async function fetchCardData() {
  try {
    // Mock data for now
    const numberOfInvoices = 12;
    const numberOfCustomers = 5;
    const totalPaidInvoices = 15000;
    const totalPendingInvoices = 5000;

    return {
      numberOfCustomers,
      numberOfInvoices,
      totalPaidInvoices,
      totalPendingInvoices,
    };
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch card data.');
  }
}

const ITEMS_PER_PAGE = 6;
export async function fetchFilteredInvoices(
  query: string,
  currentPage: number,
) {
  try {
    // Mock data for now
    const invoices: InvoicesTable[] = [
      {
        id: '1',
        customer_id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        image_url: '/customers/john-doe.png',
        date: '2023-12-06',
        amount: 15795,
        status: 'pending',
      },
      {
        id: '2',
        customer_id: '2', 
        name: 'Jane Smith',
        email: 'jane@example.com',
        image_url: '/customers/jane-smith.png',
        date: '2023-12-05',
        amount: 20348,
        status: 'paid',
      },
    ];

    return invoices;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch invoices.');
  }
}

export async function fetchInvoicesPages(query: string) {
  try {
    // Mock data - return 1 page for now
    return 1;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch total number of invoices.');
  }
}

export async function fetchInvoiceById(id: string) {
  try {
    // Mock data for now
    const invoice: InvoiceForm = {
      id: id,
      customer_id: '1',
      amount: 15795,
      status: 'pending',
    };

    return invoice;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch invoice.');
  }
}

export async function fetchCustomers() {
  try {
    const customers: CustomerField[] = [
      { id: '1', name: 'John Doe' },
      { id: '2', name: 'Jane Smith' },
      { id: '3', name: 'Bob Johnson' },
      { id: '4', name: 'Alice Wilson' },
      { id: '5', name: 'Charlie Brown' },
    ];

    return customers;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch all customers.');
  }
}

export async function fetchFilteredCustomers(query: string) {
  try {
    const data: CustomersTable[] = [
      {
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        image_url: '/customers/john-doe.png',
        total_invoices: 2,
        total_pending: 500,
        total_paid: 1000,
      },
      {
        id: '2',
        name: 'Jane Smith', 
        email: 'jane@example.com',
        image_url: '/customers/jane-smith.png',
        total_invoices: 3,
        total_pending: 800,
        total_paid: 1500,
      },
    ];

    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch customer table.');
  }
}
